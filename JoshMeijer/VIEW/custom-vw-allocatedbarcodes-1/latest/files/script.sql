CREATE VIEW Custom_VW_AllocatedBarcodes
AS
	SELECT
	TA.ID,
	TA.[User],
	TA.[Date] AS DateAllocated,
	TA.Batch,
	TE.Barcode,
	MI.Code AS ItemCode,
	MI.[Description] AS ItemDescription,
	CONVERT(FLOAT, TA.Qty) AS AllocatedQty
	FROM Custom_TrackingEntityAllocation TA
	INNER JOIN TrackingEntity TE ON TA.TrackingEntity_id = TE.ID
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TA.[Status] = 'ALLOCATED'
