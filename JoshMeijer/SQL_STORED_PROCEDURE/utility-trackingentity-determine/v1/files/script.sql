CREATE PROCEDURE [dbo].[Utility_TrackingEntity_Determine](
	@MasterItemCode varchar(50)
	,@LocationBarcode varchar(50)
	,@TrackingEntityBarcode varchar(50) OUTPUT
)
AS
IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @MasterItemCode)
BEGIN
	SELECT @TrackingEntityBarcode = @MasterItemCode
	RETURN
END
DECLARE @MasterItem_id bigint
SELECT @MasterItem_id = MasterItem_id FROM MasterItemAlias_View WHERE Code = @MasterItemCode
IF ISNULL(@MasterItem_id, 0) = 0
BEGIN
	SELECT @MasterItem_id = ID FROM MasterItem WHERE Code = @MasterItemCode OR FormattedCode = @MasterItemCode
END
IF ISNULL(@MasterItem_id, 0) > 0
BEGIN
	SELECT TOP 1 @TrackingEntityBarcode = TE.Barcode
	FROM TrackingEntity TE
	INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE TE.InStock = 1
	AND TE.OnHold = 0
	AND TE.Qty >= 0
	AND TE.MasterItem_id = @MasterItem_id
	AND L.Barcode = @LocationBarcode
	ORDER BY TE.CreatedDate
END
SELECT @TrackingEntityBarcode = ISNULL(@TrackingEntityBarcode, 'INVALID')