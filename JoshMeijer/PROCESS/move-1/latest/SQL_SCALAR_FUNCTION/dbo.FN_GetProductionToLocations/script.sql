
CREATE FUNCTION [dbo].[FN_GetProductionToLocations](@inventoryIdentifier VARCHAR(50))
RETURNS nvarchar(200) 
AS 
BEGIN
DECLARE @RetValue varchar(100)
;WITH CompletedLocations AS (
	SELECT DISTINCT [Location].Barcode [VALUE] FROM TrackingEntity
		INNER JOIN [Transaction] ON TrackingEntity.ID			= [Transaction].TrackingEntity_id
		INNER JOIN [Location]	 ON [Transaction].ToLocation_id = [Location].ID
	WHERE TrackingEntity.Barcode = @inventoryIdentifier)
, RequiredLocations AS (
	SELECT [VALUE] FROM string_split((
	SELECT Productiondescription FROM Label_TrackingEntity WHERE Barcode = @inventoryIdentifier
	
	
	
	
	)
	
	,' ')
)
	SELECT TOP 1 @RetValue = STRING_AGG(REPLACE(REQD.[VALUE],' ',','), '') 
		
	FROM RequiredLocations REQD
		LEFT JOIN CompletedLocations COMP ON REPLACE(REQD.[VALUE],' ','') = REPLACE(COMP.[VALUE],' ','')
		LEFT JOIN [PCS].dbo.PCS_StatusFlow FLOW ON REPLACE(REQD.[VALUE],' ','') = REPLACE(FLOW.Status_Description,' ','')
	WHERE ISNULL(COMP.[VALUE], '') = ''
	  AND REPLACE(REQD.[VALUE],' ','')  NOT IN ('QualityControlPlanRequired', 'CustomerInspectionHoldPoints')
	GROUP BY SequenceNumber
	ORDER BY SequenceNumber
	SELECT @RetValue = ISNULL(@RetValue,'NOTESTINGREQUIRED')
	RETURN @RetValue 
   
END
