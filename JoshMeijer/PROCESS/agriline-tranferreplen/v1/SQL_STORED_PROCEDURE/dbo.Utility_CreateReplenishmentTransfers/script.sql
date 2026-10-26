CREATE   PROCEDURE [dbo].[Utility_CreateReplenishmentTransfers]
    @Zone VARCHAR(30),
    @DocumentNumber VARCHAR(30) = NULL OUTPUT,
    @LineCount INT = NULL OUTPUT,
    @WasExisting BIT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ZoneOptionalFieldId BIGINT = 5;
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    SET @DocumentNumber = NULL;
    SET @LineCount = 0;
    SET @WasExisting = 0;
    
    SELECT ID INTO #StaleDocuments
    FROM Document
    WHERE [Type] = 'TRANSFER'
    AND Number LIKE 'RPL-%'
    AND [Status] IN ('ENTERED', 'RELEASED')
    AND CreateDate < @Today;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    IF EXISTS (SELECT 1 FROM #StaleDocuments)
    BEGIN
        DECLARE @Now DATETIME = GETDATE();
        DECLARE @DocAudit  dbo.Utility_AuditEntry;
        DECLARE @LineAudit dbo.Utility_AuditEntry;
        BEGIN TRAN;
        UPDATE d
        SET d.[Status] = 'COMPLETE',
            d.[Version] = ISNULL(d.[Version], 0) + 1,
            d.AuditDate = @Now,
            d.AuditUser = 'AUTOMATION'
        OUTPUT inserted.ID, inserted.[Version], 'Status', deleted.[Status], inserted.[Status]
            INTO @DocAudit (RecordID, RecordVersion, ColumnName, PreviousValue, NewValue)
        FROM Document d
        INNER JOIN #StaleDocuments sd ON sd.ID = d.ID;
        UPDATE dd
        SET dd.Completed = 1,
            dd.[Version] = ISNULL(dd.[Version], 0) + 1,
            dd.AuditDate = @Now,
            dd.AuditUser = 'AUTOMATION'
        OUTPUT inserted.ID, inserted.[Version], 'Completed',
               CASE deleted.Completed WHEN 1 THEN 'True' ELSE 'False' END,
               CASE inserted.Completed WHEN 1 THEN 'True' ELSE 'False' END
            INTO @LineAudit (RecordID, RecordVersion, ColumnName, PreviousValue, NewValue)
        FROM DocumentDetail dd
        INNER JOIN #StaleDocuments sd ON sd.ID = dd.Document_id
        WHERE dd.Completed = 0
        AND ISNULL(dd.Cancelled, 0) = 0;
        EXEC dbo.Utility_WriteAudit
            @TableName = 'Document', @Entries = @DocAudit,
            @Application = 'Utility_CreateReplenishmentTransfers';
        EXEC dbo.Utility_WriteAudit
            @TableName = 'DocumentDetail', @Entries = @LineAudit,
            @Application = 'Utility_CreateReplenishmentTransfers';
        COMMIT TRAN;
    END
    DROP TABLE #StaleDocuments;
    
    SELECT TOP 1 @DocumentNumber = d.Number
    FROM Document d
    INNER JOIN DocumentDetail dd ON dd.Document_id = d.ID
    INNER JOIN OptionalFieldValues_DocumentDetail ofdd
        ON ofdd.BelongsTo_id = dd.ID AND ofdd.OptionalField_id = @ZoneOptionalFieldId
    WHERE d.[Type] = 'TRANSFER'
    AND d.Number LIKE 'RPL-%'
    AND d.[Status] IN ('ENTERED', 'RELEASED')
    AND ofdd.[Value] = @Zone;
    IF @DocumentNumber IS NOT NULL
    BEGIN
        SET @WasExisting = 1;
        SELECT @LineCount = COUNT(*)
        FROM DocumentDetail dd
        INNER JOIN Document d ON d.ID = dd.Document_id
        WHERE d.Number = @DocumentNumber
        AND ISNULL(dd.Cancelled, 0) = 0;
        RETURN;
    END
    
    ;WITH PickZoneQty AS (
        SELECT te.MasterItem_id, SUM(te.Qty) AS Qty
        FROM TrackingEntity te
        INNER JOIN [Location] l ON te.Location_id = l.ID
        WHERE l.[Type] = 'PICK' AND te.InStock = 1 AND l.Category = @Zone
        GROUP BY te.MasterItem_id
    ),
    ItemStagingTotal AS (
        SELECT te.MasterItem_id, SUM(te.Qty) AS Qty
        FROM TrackingEntity te
        INNER JOIN [Location] l ON te.Location_id = l.ID
        WHERE l.[Type] = 'STAGING' AND te.InStock = 1
        GROUP BY te.MasterItem_id
    ),
    BulkAvailability AS (
        SELECT te.MasterItem_id, SUM(te.Qty) AS Qty
        FROM TrackingEntity te
        INNER JOIN [Location] l ON te.Location_id = l.ID
        WHERE l.[Type] = 'BULK' AND te.Qty > 0 AND te.InStock != 0
        GROUP BY te.MasterItem_id
    ),
    Candidates AS (
        SELECT
            pz.MasterItem_id,
            mi.Code,
            CEILING(
                (TRY_CAST(ofm2.[Value] AS DECIMAL(18,4)) / 365 * TRY_CAST(ofm3.[Value] AS DECIMAL(18,4)))
                - pz.Qty - ISNULL(ist.Qty, 0)
            ) AS ShortfallQty
        FROM PickZoneQty pz
        INNER JOIN MasterItem mi ON mi.ID = pz.MasterItem_id
        LEFT JOIN OptionalFieldValues_MasterItem ofm  ON pz.MasterItem_id = ofm.BelongsTo_id  AND ofm.OptionalField_id = 4
        LEFT JOIN OptionalFieldValues_MasterItem ofm2 ON pz.MasterItem_id = ofm2.BelongsTo_id AND ofm2.OptionalField_id = 2
        LEFT JOIN OptionalFieldValues_MasterItem ofm3 ON pz.MasterItem_id = ofm3.BelongsTo_id AND ofm3.OptionalField_id = 3
        LEFT JOIN ItemStagingTotal ist ON ist.MasterItem_id = pz.MasterItem_id
        WHERE ofm2.[Value] IS NOT NULL AND ofm3.[Value] IS NOT NULL
        AND (pz.Qty + ISNULL(ist.Qty, 0))
            < TRY_CAST(ofm2.[Value] AS DECIMAL(18,4)) / 365 * TRY_CAST(ofm3.[Value] AS DECIMAL(18,4)) * (TRY_CAST(ofm.[Value] AS DECIMAL(18,4)) / 100.0)
        AND EXISTS (SELECT 1 FROM BulkAvailability ba WHERE ba.MasterItem_id = pz.MasterItem_id)
        AND NOT EXISTS (
            SELECT 1
            FROM DocumentDetail dd
            INNER JOIN Document d ON d.ID = dd.Document_id
            WHERE dd.Item_id = pz.MasterItem_id
            AND d.Type = 'TRANSFER'
            AND d.Number LIKE 'RPL-%'
            AND d.Status IN ('ENTERED', 'RELEASED')
            AND dd.Completed = 0
            AND ISNULL(dd.Cancelled, 0) = 0
        )
    )
    SELECT DISTINCT * INTO #Candidates FROM Candidates;
    IF EXISTS (SELECT 1 FROM #Candidates)
    BEGIN
        DECLARE @DocumentId BIGINT;
        DECLARE @Suffix INT = 0;
        DECLARE @DateStamp VARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd');
        SET @DocumentNumber = 'RPL-' + LEFT(@Zone, 12) + '-' + @DateStamp;
        WHILE EXISTS (SELECT 1 FROM Document WHERE Number = @DocumentNumber)
        BEGIN
            SET @Suffix += 1;
            SET @DocumentNumber = 'RPL-' + LEFT(@Zone, 12) + '-' + @DateStamp + '-' + FORMAT(@Suffix, '00');
        END
        DECLARE @Inserted TABLE (DocumentDetail_id BIGINT);
        BEGIN TRAN;
        INSERT INTO Document (
            [Number], [Type], [Status], [Description], [CreateDate], [isActive], [AuditDate], [AuditUser], [Version], [ERPSyncFailed]
        )
        VALUES (
            @DocumentNumber, 'TRANSFER', 'ENTERED',
            'Auto-generated replenishment run - Zone ' + @Zone + ' ' + CONVERT(VARCHAR(19), GETDATE(), 120),
            GETDATE(), 1, GETDATE(), 'AUTOMATION', 1, 0
        );
        SET @DocumentId = SCOPE_IDENTITY();
        INSERT INTO DocumentDetail (
            [Document_id], [Item_id], [LineNumber], [Qty], [FromLocation], [ToLocation],
            [Completed], [Cancelled], [ERPSyncFailed]
        )
        OUTPUT inserted.ID INTO @Inserted (DocumentDetail_id)
        SELECT
            @DocumentId,
            c.MasterItem_id,
            CAST(ROW_NUMBER() OVER (ORDER BY c.Code) AS VARCHAR(50)),
            c.ShortfallQty,
            'CPT',
            'CPT',
            0, 0, 0
        FROM #Candidates c;
        INSERT INTO OptionalFieldValues_DocumentDetail (Value, OptionalField_id, BelongsTo_id)
        SELECT @Zone, @ZoneOptionalFieldId, DocumentDetail_id
        FROM @Inserted;
        COMMIT TRAN;
        SELECT @LineCount = COUNT(*) FROM @Inserted;
    END
    DROP TABLE #Candidates;
END