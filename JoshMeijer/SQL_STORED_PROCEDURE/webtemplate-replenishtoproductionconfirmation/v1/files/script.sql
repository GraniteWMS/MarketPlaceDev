
CREATE PROCEDURE [dbo].[WebTemplate_ReplenishToProductionConfirmation]
@Reference NVARCHAR(100)  
AS
BEGIN
	SELECT    TE.Barcode, MI.Code, TX.ActionQty, TX.Date,isnull(TX.DocumentReference,'No Ref') AS Reference,TX.IntegrationReference
	FROM       [Transaction] TX 
	INNER JOIN MasterItem MI ON TX.FromMasterItem_id = MI.ID
	INNER JOIN TrackingEntity TE ON TX.FromTrackingEntity_id = TE.ID
	WHERE TX.[Type] = 'REPLENISH' 
	AND TX.[Process] = 'REPLENISHTOPRODUCTION' 
	AND TX.DocumentReference = @Reference
END
