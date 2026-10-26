CREATE PROCEDURE [dbo].[SSRS_Transfersheet_Detail]
    @DocumentNumber NVARCHAR(50)
AS
BEGIN
WITH
PickedItems AS (
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
		mi.ShelfLife,
		dateadd(day,mi.ShelfLife,te.ManufactureDate) as ExpiryDate,
		FORMAT(TE.ManufactureDate,'yyyy-MM') AS ManufactureDate,
        TE.Barcode AS Pallet,
		T.IntegrationReference as Shipment
    FROM [Transaction] T
    INNER JOIN Document D ON D.ID = T.Document_id
    INNER JOIN DocumentDetail DD ON DD.ID = T.DocumentLine_id
    INNER JOIN MasterItem MI ON MI.ID = T.FromMasterItem_id
    INNER JOIN TrackingEntity TE ON TE.ID = T.TrackingEntity_id
    WHERE T.[Type] = 'TRANSFER' AND ReversalTransaction_id = 0
	AND D.Number = @DocumentNumber
)
SELECT
    CONVERT(BIGINT, PII.LineNumber) as [Line],
	PII.Code AS [Item Code],
    PII.[Description] AS [Item Description],
	PII.UOM,
    PII.Batch,
	PII.ManufactureDate,
	PII.ExpiryDate,
	PII.DocumentNumber,
	PII.Shipment,
   CONVERT(BIGINT, SUM(PII.PickedQty)) AS [Total Picked Qty],
	COUNT(Pallet) as [PickedPallets],
	CONVERT(DECIMAL(19, 2), SUM(PII.UnitWeight * PII.PickedQty)) as LineWeight
FROM PickedItems PII
GROUP BY
	PII.[LineNumber],
    PII.Code,
    PII.[Description],
	PII.UOM,
    PII.Batch,
	PII.ManufactureDate,
	PII.ExpiryDate,
	PII.DocumentNumber,
	PII.Shipment
END
