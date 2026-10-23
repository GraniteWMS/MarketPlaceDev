CREATE PROCEDURE [dbo].[Utility_GetTopTrackingEntity]
     @MasterItemID BIGINT
	,@LocationBarcode VARCHAR(50)
	,@TrackingEntityBarcode VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 @TrackingEntityBarcode = TE.Barcode
    FROM TrackingEntity TE
    INNER JOIN [Location] L ON L.ID = TE.Location_id
    WHERE TE.MasterItem_id = @MasterItemID
      AND L.Barcode = @LocationBarcode
      AND TE.OnHold <> 1
      AND TE.InStock <> 0
      AND TE.Qty <> 0
    ORDER BY TE.CreatedDate ASC;  
END
