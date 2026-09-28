CREATE PROCEDURE [dbo].[PrescriptGenerateLoadSheetType] (
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
DECLARE @EmailList varchar(max)
DECLARE @Printer varchar(100)
IF @stepInput = 'EMAIL'
BEGIN
	SELECT @EmailList = [Value]
	FROM SystemStaticData
	WHERE [Group] = 'Email'
	  AND [Key] = 'LoadSheet'
	
	SELECT @valid = 1
	SELECT @message = CONCAT('Email selected. Email list :',@EmailList)
END
ELSE IF @stepInput = 'PRINT'
BEGIN
	SELECT @Printer = [Value]
	FROM SystemStaticData
	WHERE [Group] = 'Printer'
	  AND [Key] = 'DocumentPrinter'
	SELECT @valid = 1
	SELECT @message = CONCAT('Print selected. Printer :',@Printer)
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Invalid Selection.'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
