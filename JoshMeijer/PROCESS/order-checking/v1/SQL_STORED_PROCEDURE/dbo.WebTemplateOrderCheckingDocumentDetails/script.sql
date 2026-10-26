




CREATE PROCEDURE [dbo].[WebTemplateOrderCheckingDocumentDetails]
	
	@Document varchar(50)
AS
BEGIN
	
	
	SET NOCOUNT ON;

    SELECT Code, MasterItem.Description, SUM(ISNULL(ActionQty, 0)) as Picked, SUM(ISNULL(PackedQty, 0)) as Checked
	FROM DocumentDetail INNER JOIN
	MasterItem ON DocumentDetail.Item_id = MasterItem.ID INNER JOIN
	Document ON DocumentDetail.Document_id = Document.ID
	WHERE Document.Number = @Document
	GROUP BY Code, MasterItem.Description
END
