CREATE VIEW [dbo].[Webtemplate_AssignProductionProductionLine]
AS
SELECT L.Barcode AS LocationBarcode, L.[Name] AS LocationName, MI.Code AS ItemCode, MI.[Description] AS ItemDescription, CPLA.PreformMasterItem as [Preform], CPLA.CurrentBatch as Lot, CPLA.PalletsPerBatch, CPLA.BottlesPerPallet,
CASE WHEN L.Barcode = 'PACKOUT' THEN 'L5' ELSE SUBSTRING(L.Barcode,1,1) + SUBSTRING(L.Barcode,5,1) END AS Printer
FROM [Location] L 
LEFT JOIN Custom_ProductionLineAssignments CPLA ON CPLA.ProductionLine = L.Barcode
												AND CPLA.IsActive = 1
LEFT JOIN MasterItem MI ON MI.Code = CPLA.MasterItem
WHERE L.[Type] = 'PRODUCTION' and L.isActive = 1
