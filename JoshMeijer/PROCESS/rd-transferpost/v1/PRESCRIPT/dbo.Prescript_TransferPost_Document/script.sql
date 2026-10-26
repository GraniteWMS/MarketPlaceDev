CREATE PROCEDURE [dbo].[Prescript_TransferPost_Document] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(50) = @stepInput
DECLARE @TransferPostCompleteRule Decimal(10,2)
DECLARE @UserName varchar(20) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @DocumentProgress Decimal(10,2)
BEGIN TRY
	SELECT @TransferPostCompleteRule = isnull([Value],0.0)
	FROM SystemStaticData
	WHERE [Group] = 'Rules' and [key] = 'TransferPostCompletePercentage'
	SELECT @DocumentProgress = Progress FROM API_QueryDocumentProgress WHERE Number = @Document
	IF  @DocumentProgress <= @TransferPostCompleteRule
		RAISERROR('You cannot post this Transfer - it is not sufficiently complete.',16,1)
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
