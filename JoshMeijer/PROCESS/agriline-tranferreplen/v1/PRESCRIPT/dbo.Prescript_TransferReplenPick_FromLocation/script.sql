CREATE PROCEDURE [dbo].[Prescript_TransferReplenPick_FromLocation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = TRIM(Value) FROM @input WHERE Name = 'StepInput'
BEGIN TRY
	IF @stepInput = 'GOODSIN'
		RAISERROR('ERROR: Cannot move from GOODSIN, use putaway.', 16, 1)
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
