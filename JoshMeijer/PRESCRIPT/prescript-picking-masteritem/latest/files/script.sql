CREATE PROCEDURE [dbo].[Prescript_Picking_MasterItem] (
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
DECLARE 
@MasterItemID bigint,
@MasterItem varchar(50)
BEGIN TRY
	SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = @stepInput
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = SUBSTRING(@stepInput, 1, LEN(@stepInput) - 1)
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = CONCAT('0', @stepInput)
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT TOP 1 @MasterItemID = MasterItem_id FROM MasterItemAlias_View WHERE Code = CONCAT(@stepInput, '5')
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		SELECT @MasterItemID = ID FROM MasterItem WHERE Code = @stepInput
	END
	IF ISNULL(@MasterItemID, 0) = 0
	BEGIN
		RAISERROR('Item code could not be determined based on input (%s)', 16, 1, @stepInput)
	END
	SELECT @MasterItem = Code FROM MasterItem WHERE ID = @MasterItemID
	SELECT @stepInput = @MasterItem
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
