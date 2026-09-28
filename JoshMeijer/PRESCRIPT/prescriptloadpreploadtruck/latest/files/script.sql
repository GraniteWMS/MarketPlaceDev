CREATE PROCEDURE [dbo].[PrescriptLoadPrepLoadTruck] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
DECLARE @User varchar(25)
DECLARE @Printer varchar(10)
DECLARE @LoadNumber varchar(50)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'	
SELECT @LoadNumber =  'LD-' + CONVERT(varchar(10), getdate(),10) +'-'+ @StepInput
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @Printer = Value FROM @input WHERE Name = 'printerName'
SELECT @message = @LoadNumber
INSERT INTO @Output
SELECT 'LoadNumber', @LoadNumber
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
