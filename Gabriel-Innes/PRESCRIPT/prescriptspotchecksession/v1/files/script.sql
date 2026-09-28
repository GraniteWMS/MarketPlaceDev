CREATE PROCEDURE [dbo].[PrescriptSpotCheckSession] (
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
DECLARE @Cage varchar(100)
DECLARE @SessionName varchar(100)
	SELECT @SessionName = @stepInput
BEGIN TRY
	IF((ISNULL((SELECT 1 FROM StockTakeSession WHERE Name = @stepInput),0)) <> 1 AND @stepInput <> 'NEW')
	BEGIN 
		SELECT @valid = 0, @message = @stepInput + ' is not valid. Please select an active session or NEW'
	END
	ELSE
	BEGIN 
	    IF(@stepInput = 'NEW')
		BEGIN
			SELECT @Cage = Value from @input where Name = 'Cage'
			SELECT @SessionName = @Cage + '-' + CONVERT(varchar, GETDATE(), 23) 
			
			INSERT INTO StockTakeSession (Name, CreateDate, Site, Active)
			SELECT @SessionName, GETDATE(), '', 1
			WHERE NOT EXISTS (
				SELECT 1 FROM StockTakeSession WHERE Name = @SessionName
			);
			SELECT @stepInput = @SessionName
		END
		SELECT @valid = 1, @message = @SessionName
	END
END TRY
BEGIN CATCH
	SELECT @message = ERROR_MESSAGE()
	SELECT @valid = 0
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
