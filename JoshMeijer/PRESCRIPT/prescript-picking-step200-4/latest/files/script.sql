CREATE PROCEDURE  [dbo].[Prescript_Picking_Step200] (
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
DECLARE @success bit
DECLARE @DocumentNumber varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
BEGIN TRY
	EXEC Utility_Document_PickSequence
	@DocumentNumber = @DocumentNumber
	,@success = @success OUTPUT
    ,@Message = @message OUTPUT
	IF @success = 0
		RAISERROR(@message, 16, 1)
	SELECT @valid = 1
	,@message = @message
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