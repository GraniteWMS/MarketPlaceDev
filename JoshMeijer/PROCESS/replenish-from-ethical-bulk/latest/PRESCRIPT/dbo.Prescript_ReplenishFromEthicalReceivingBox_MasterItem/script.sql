CREATE PROCEDURE [dbo].[Prescript_ReplenishFromEthicalReceivingBox_MasterItem] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItemID bigint
,@MasterItem varchar(50)
BEGIN TRY
	EXECUTE [dbo].[Common_SP_GetMasterItemLinkedToAlias] 
   @Alias = @stepInput
  ,@MasterItemCode = @MasterItem OUTPUT
  ,@MasterItemID = @MasterItemID OUTPUT
	IF ISNULL(@MasterItem, '') = ''
	BEGIN
			RAISERROR('Cannot determine master item', 16, 1)
	END
	
	SET @stepInput = @MasterItem
	SELECT 
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
