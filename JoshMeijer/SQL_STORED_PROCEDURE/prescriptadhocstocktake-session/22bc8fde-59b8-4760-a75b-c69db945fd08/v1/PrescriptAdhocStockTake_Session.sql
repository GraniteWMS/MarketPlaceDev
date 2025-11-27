CREATE PROCEDURE [dbo].[PrescriptAdhocStockTake_Session] (
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
SELECT @stepInput = LTRIM(RTRIM(@stepInput))
DECLARE @SessionName varchar (50)
SELECT @SessionName = LTRIM(RTRIM(@stepInput))
	IF NOT EXISTS (SELECT ID FROM StockTakeSession WHERE [Name] = @SessionName)
	BEGIN
		IF LEN(@SessionName) < 21
			BEGIN
				INSERT INTO StockTakeSession ([Name], [CreateDate], [Active])
				SELECT @SessionName, GETDATE(), 1
				SELECT @valid = 1
				SELECT @message = CONCAT('Session ', @SessionName, ' created successfully')
			END
		ELSE 
		BEGIN
			SELECT @valid = 0
			SELECT @message = CONCAT('A session name cannot exceed 20 characters. ', LEN(@SessionName), ' characters have been entered')
		END
	END
	ELSE
	BEGIN
		SELECT @valid = 1
	END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
