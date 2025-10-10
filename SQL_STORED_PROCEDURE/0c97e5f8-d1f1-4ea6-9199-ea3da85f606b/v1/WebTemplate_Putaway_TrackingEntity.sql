CREATE PROCEDURE [dbo].[WebTemplate_Putaway_TrackingEntity]
@TrackingEntityBarcode NVARCHAR(100)  
AS
BEGIN


DECLARE @TrackingEntity_ID BIGINT
DECLARE @MasterItem_ID BIGINT
SELECT @MasterItem_ID = MI.ID FROM TrackingEntity TE INNER JOIN
MasterItem MI ON TE.MasterItem_id = MI.ID
WHERE TE.Barcode = @TrackingEntityBarcode

SELECT 'PICKINGLOCATION' as [Type],L.Barcode AS [Location] 
FROM MasterItem MI INNER JOIN 
Location L ON MI.PickfaceLocation_id = L.ID
WHERE MI.ID = @MasterItem_ID
UNION


SELECT TOP 3 'BULK' as [Type] ,Barcode as [Location] FROM API_QueryLocations
WHERE isnull(Inventory,0) <1 and [Type]  IN ('BULK')



select * from MasterITem
END




