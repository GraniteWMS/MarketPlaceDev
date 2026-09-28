CREATE PROCEDURE [dbo].[PrescriptTransferOffsiteLocation] (
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
DECLARE @Comment varchar(50)
SELECT @Comment =  CONVERT(varchar(10), getdate(),10)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'
SELECT @User = Value FROM @input WHERE Name = 'User'
SELECT @Printer = Value FROM @input WHERE Name = 'printerName'
SELECT @message = @Comment
INSERT INTO @Output
SELECT 'Comment', @Comment
INSERT INTO @Output
SELECT 'Reference', @Comment
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
