CREATE PROCEDURE [dbo].[Utility_Document_PickSequence]
	@DocumentNumber varchar(50)
    ,@success bit OUTPUT
    ,@message varchar(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN
        SET @message = NULL;
        SET @success = 0;
        DECLARE @PickLocation TABLE (
            DocumentDetail_id int NOT NULL
            ,LocationBarcode varchar(30) NULL
            ,Instruction varchar(200) NULL
            ,rn int NOT NULL,
            PRIMARY KEY (DocumentDetail_id, rn)
        );
        INSERT INTO @PickLocation (
            DocumentDetail_id
            ,LocationBarcode
            ,Instruction
            ,rn
        )
        SELECT
        DD.ID
        ,L.Barcode
        ,CONCAT('Pick from: ', L.Barcode, ' | Qty: ', CAST(TE.Qty AS int), ' | TE: ', TE.Barcode) AS Instruction
        ,ROW_NUMBER() OVER (
            PARTITION BY DD.ID
            ORDER BY
                CASE 
                    WHEN ISNULL(D.[Description], '') LIKE 'ODS%' AND L.[Type] = 'PICK' THEN 1
                    WHEN ISNULL(D.[Description], '') LIKE 'ODS%' AND L.[Type] = 'BULK' THEN 2
                    WHEN D.Number LIKE 'TR-%' AND L.[Type] = 'PICK' THEN 1
                    WHEN D.Number LIKE 'TR-%' AND L.[Type] = 'BULK' THEN 2
                    ELSE 3
                END
        ) AS rn
        FROM DocumentDetail DD
        INNER JOIN Document D ON D.ID = DD.Document_id
        INNER JOIN TrackingEntity TE ON TE.MasterItem_id = DD.Item_id
        INNER JOIN [Location] L ON L.ID = TE.Location_id
        WHERE
        D.Number = @DocumentNumber
        AND TE.InStock = 1
        AND TE.OnHold = 0
        AND TE.Qty > 0
        AND L.[Type] IN ('PICK', 'BULK')
        AND L.ERPLocation = D.ERPLocation
        ORDER BY TE.CreatedDate DESC
        UPDATE DD
        SET Instruction = ISNULL(PL.Instruction, 'No Stock')
        FROM DocumentDetail DD
        INNER JOIN Document D ON D.ID = DD.Document_id
        LEFT JOIN @PickLocation PL ON PL.DocumentDetail_id = DD.ID
                                   AND PL.rn = 1
        WHERE D.Number = @DocumentNumber;
        MERGE OptionalFieldValues_DocumentDetail AS T
        USING (
            SELECT
            DocumentDetail_id
            ,LocationBarcode
            FROM @PickLocation
            WHERE rn = 1
        ) AS S
        ON  T.BelongsTo_id = S.DocumentDetail_id
        AND T.OptionalField_id = 1
        WHEN MATCHED THEN
            UPDATE SET T.[Value] = S.LocationBarcode
        WHEN NOT MATCHED THEN
            INSERT ([Value], OptionalField_id, BelongsTo_id)
            VALUES (S.LocationBarcode, 1, S.DocumentDetail_id);
        COMMIT TRAN
        SET @Success = 1;
        SET @Message = 'Document pick locations updated.';
    END TRY
    BEGIN  CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN
        SET @success = 0
        SET @message = CONCAT('Error ',ERROR_NUMBER(),' (Line ',ERROR_LINE(),'): ',ERROR_MESSAGE());
    END CATCH
END