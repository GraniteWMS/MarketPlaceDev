
CREATE PROCEDURE [dbo].[WebTemplate_TransferOffsiteConfirmation]
@Comment NVARCHAR(100)  
AS
BEGIN
	SELECT     MI.Code, TX.ActionQty,TX.IntegrationReference, TX.Date,isnull(TX.Comment,'No Ref') AS Reference
	FROM            dbo.[Transaction] TX INNER JOIN 
	dbo.MasterItem MI ON TX.FromMasterItem_id = MI.ID
	WHERE       	 TX.[Process] = 'TRANSFEROFFSITE' and Comment = @Comment
END
