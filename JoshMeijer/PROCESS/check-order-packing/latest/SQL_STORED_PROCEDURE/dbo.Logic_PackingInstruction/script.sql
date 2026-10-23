




CREATE PROCEDURE [dbo].[Logic_PackingInstruction]
	
	@Document varchar(50)
AS
BEGIN


	UPDATE DocumentDetail SET Instruction = isnull('Stock:' + (SELECT TOP 1  L.Barcode + ' (OnHand:' + CONVERT(varchar,(CONVERT(int,TE.Qty))) + ')'
	FROM TrackingEntity TE Inner Join Location L
	ON TE.Location_id = L.ID
	WHERE TE.InStock = 1 AND TE.OnHold = 0 AND TE.Qty > 0  and L.NonStock = 0 and L.isActive = 1
	AND TE.MasterItem_id=  DocumentDetail.Item_id AND L.ERPLocation = DocumentDetail.FromLocation 
	ORDER BY L.[Type],TE.ExpiryDate,TE.CreatedDate),'ZZZ-No Stock')
	FROM DocumentDetail INNER JOIN Document ON Document.ID = DocumentDetail.Document_id
	WHERE Document.Number = @Document

















END

