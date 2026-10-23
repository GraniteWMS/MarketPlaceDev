CREATE PROCEDURE [dbo].[WebtemplateShortpickLine]
	@Document varchar(30) 
AS
BEGIN
 
	SELECT DocumentDetail.ID, 
		MasterItem.Code, 
		MasterItem.Description, 
		(DocumentDetail.Qty - DocumentDetail.ActionQty) AS OutstandingQty
	FROM Document INNER JOIN 
		DocumentDetail ON Document.ID = DocumentDetail.Document_id INNER JOIN
		MasterItem ON DocumentDetail.Item_id = MasterItem.ID
	WHERE Document.Number = @Document AND
	      DocumentDetail.Completed = 0 AND
		  DocumentDetail.Cancelled = 0
END

