CREATE VIEW [dbo].[WebTemplateConsumeReversal]
AS 
	SELECT TR.ID AS TransactionID, D.Number AS DocumentNumber, TE.Barcode AS TrackingEntity, MI.Code AS ItemCode, TE.Batch, TR.ActionQty
	FROM [Transaction] TR 
	INNER JOIN TrackingEntity TE ON TR.TrackingEntity_id = TE.ID
	INNER JOIN Document D ON TR.Document_id = D.ID
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TR.[Type] = 'CONSUME'
	  AND ISNULL(TR.ReversalTransaction_id,0) = 0
