CREATE PROCEDURE [dbo].[SSRS_Loadsheet_Detail]
    @DocumentNumber NVARCHAR(50),
    @Shipment       NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    WITH PickedItems AS
    (
        SELECT
            DD.LineNumber,
            MI.Code,
            MI.[Description],
            T.ActionQty AS PickedQty,
            DD.UOM,
            MI.UnitWeight,
            D.Number AS DocumentNumber,
            DD.FromLocation,
            TE.Batch,
            MI.ShelfLife,
            DATEADD(DAY, MI.ShelfLife, TE.ManufactureDate) AS ExpiryDate,
            FORMAT(TE.ManufactureDate, 'yyyy-MM') AS ManufactureDate,
            TE.Barcode AS Pallet,
            T.IntegrationReference AS Shipment
        FROM [Transaction] T
        INNER JOIN Document D
            ON D.ID = T.Document_id
        INNER JOIN DocumentDetail DD
            ON DD.ID = T.DocumentLine_id
        INNER JOIN MasterItem MI
            ON MI.ID = T.FromMasterItem_id
        INNER JOIN TrackingEntity TE
            ON TE.ID = T.TrackingEntity_id
        WHERE
            T.[Type] = 'PICK'
            AND ISNULL(T.ReversalTransaction_id, 0) = 0
            AND D.Number = @DocumentNumber
            
    )
    SELECT
        CONVERT(BIGINT, PII.LineNumber) AS [Line],
        PII.Code AS [Item Code],
        PII.[Description] AS [Item Description],
        PII.UOM,
        PII.Batch,
        PII.ManufactureDate,
        PII.ExpiryDate,
        PII.DocumentNumber,
        PII.Shipment,
        CONVERT(BIGINT, SUM(PII.PickedQty)) AS [Total Picked Qty],
        COUNT(PII.Pallet) AS [PickedPallets],
        CONVERT(
            DECIMAL(19, 2),
            SUM(PII.UnitWeight * PII.PickedQty)
        ) AS LineWeight
    FROM PickedItems PII
    GROUP BY
        PII.LineNumber,
        PII.Code,
        PII.[Description],
        PII.UOM,
        PII.Batch,
        PII.ManufactureDate,
        PII.ExpiryDate,
        PII.DocumentNumber,
        PII.Shipment
    ORDER BY
        [Line],
        [Item Code],
        Batch;
END
