CREATE PROCEDURE [dbo].[Prescript_PackingCustom_ItemCode] (
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
DECLARE @userName nvarchar(max) = (SELECT [Value] FROM @input WHERE [Name] = 'User')
DECLARE @documentNumber nvarchar(max) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
DECLARE @lineNumber nvarchar(max)
DECLARE @carryingEntityIdentifier nvarchar(max) = @documentNumber
DECLARE @masterItemIdentifier nvarchar(max) = @stepInput
DECLARE @locationIdentifier nvarchar(max) = 'DISPATCH'
DECLARE @qty numeric(19,4) = 1
DECLARE @comment nvarchar(max)
DECLARE @reference nvarchar(max)
DECLARE @integrationReference nvarchar(max)
DECLARE @processName nvarchar(max) = 'PACKING'
DECLARE @businessRules nvarchar(max)
DECLARE @success bit
DECLARE @MasterItem_id bigint
DECLARE @MasterItemWeight decimal(19, 4)
SELECT 
@MasterItem_id = ID
,@MasterItemWeight = UnitWeight
FROM MasterItem
WHERE Code = @stepInput
SELECT @lineNumber = LineNumber FROM DocumentDetail WHERE Item_id = @MasterItem_id
BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM MasterItem WHERE Code = @stepInput)
		RAISERROR('%s is not a valid item.', 16, 1, @stepInput)
	EXECUTE [dbo].[clr_Pack] 
	   @userName
	  ,@documentNumber
	  ,@lineNumber
	  ,@carryingEntityIdentifier
	  ,@masterItemIdentifier
	  ,@locationIdentifier
	  ,@qty
	  ,@comment
	  ,@reference
	  ,@integrationReference
	  ,@processName
	  ,@businessRules
	  ,@success OUTPUT
	  ,@message OUTPUT
	IF @success = 1
	BEGIN
		UPDATE CarryingEntity
		SET [Weight] = [Weight] + @MasterItemWeight
		WHERE Barcode = @documentNumber
	END
	ELSE
	BEGIN
		RAISERROR(@message, 16, 1)
	END
	SELECT @valid = 1
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
