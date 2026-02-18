
CREATE PROCEDURE [dbo].[Utility_GenerateBomDocument]
    @OutputItemNumber varchar(30),
    @LoopCount int,
    @StartBarcode int,
    @valid bit OUTPUT,
    @message varchar(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
    @OutputItemQty decimal(19, 4)
    ,@OutputItem_id bigint
    ,@OutputItemUOM varchar(10);

    DECLARE @InsertedDocuments TABLE (
        Document_id bigint,
        DocumentNumber varchar(50)
    );

    BEGIN TRY

        ;WITH Tally AS (
            SELECT TOP (@LoopCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
            FROM sys.all_objects
        ),
        Barcodes AS (
            SELECT
            rn,
            @StartBarcode + rn - 1 AS BarcodeValue,
            RIGHT('000000' + CAST(@StartBarcode + rn - 1 AS varchar(6)), 6) AS PaddedBarcode
            FROM Tally
        ),
        NewDocuments AS (
            SELECT
            CONCAT(@OutputItemNumber, '-', PaddedBarcode) AS DocumentNumber,
            GETDATE() AS CreateDate,
            rn
            FROM Barcodes
        )
        INSERT INTO Document (
            Number, [Type], [Status], CreateDate, isActive, ERPLocation, [Site],
            AuditDate, AuditUser, [Version]
        )
        OUTPUT INSERTED.ID, INSERTED.Number INTO @InsertedDocuments
        SELECT 
        nd.DocumentNumber,
        'WORKORDER',
        'ENTERED',
        nd.CreateDate,
        1,
        'PIE',
        '',
        nd.CreateDate,
        'AUTOMATION',
        1
        FROM NewDocuments nd;

        SELECT
        @OutputItemQty = MAX(c.BUILDQTY),
        @OutputItem_id = miOutput.ID,
        @OutputItemUOM = miOutput.UOM
        FROM Custom_BomDetails c
        INNER JOIN MasterItem miOutput ON miOutput.Code = c.ITEMNO
        WHERE c.ITEMNO = @OutputItemNumber
        GROUP BY miOutput.ID, miOutput.UOM;

        ;WITH Mix AS (
            SELECT 
            m.ITEMNO,
            miMix.ID AS MixItem_id,
            miMix.UOM AS MixItemUOM,
            SUM(m.QTY) AS MixItemQty
            FROM Custom_BomDetails m
            LEFT JOIN MasterItem miMix ON miMix.Code = m.MIXCODE
            WHERE m.UNIT IN ('KG', 'LT')
            AND ISNULL(ISWETCODE, '') <> 'YES'
            AND m.ITEMNO = @OutputItemNumber
            GROUP BY m.ITEMNO, miMix.ID, miMix.UOM
        ),
        OptionalItems AS (
            SELECT 
            c.ITEMNO,
            mi.ID AS Item_id,
            mi.UOM,
            SUM(c.QTY) AS Qty,
            'INPUT' AS DetailType
            FROM Custom_BomDetails c
            INNER JOIN MasterItem mi ON mi.Code = c.COMPONENT
            INNER JOIN OptionalFields opf ON opf.Name = 'Remove From Dry Mix'
            INNER JOIN OptionalFieldValues_MasterItem opfv ON opfv.OptionalField_id = opf.ID
                                                           AND opfv.BelongsTo_id = mi.ID
                                                           AND opfv.[Value] = 'Yes'
            WHERE c.ITEMNO = @OutputItemNumber
            GROUP BY c.ITEMNO, mi.ID, mi.UOM
        )
       
        INSERT INTO DocumentDetail (
            Document_id, Item_id, LineNumber, Qty, UOM, FromLocation, ToLocation, [Type]
        )
        SELECT d.Document_id, Details.Item_id, Details.LineNumber, Details.Qty, Details.UOM, 'PIE', 'PIE', Details.DetailType
        FROM @InsertedDocuments d
        CROSS APPLY (
            SELECT @OutputItem_id AS Item_id, 0 AS LineNumber, @OutputItemQty AS Qty, @OutputItemUOM AS UOM, 'OUTPUT' AS DetailType
            UNION ALL
            SELECT m.MixItem_id, ROW_NUMBER() OVER (ORDER BY m.MixItem_id) AS LineNumber, m.MixItemQty, m.MixItemUOM, 'INPUT'
            FROM Mix m
            WHERE m.MixItem_id IS NOT NULL
            UNION ALL
            SELECT o.Item_id, ROW_NUMBER() OVER (ORDER BY o.Item_id) + (SELECT COUNT(*) FROM Mix) AS LineNumber, o.Qty, o.UOM, o.DetailType
            FROM OptionalItems o
            WHERE o.Item_id IS NOT NULL
        ) AS Details;

        SELECT @valid = 1
        ,@message = 'Bom documents successfully created';

    END TRY
    BEGIN CATCH

        SELECT @valid = 0
        ,@message = ERROR_MESSAGE();

    END CATCH
END


