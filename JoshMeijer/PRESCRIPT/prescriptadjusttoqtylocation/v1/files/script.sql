CREATE PROCEDURE [dbo].[PrescriptAdjustToQtyLocation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit=1
DECLARE @message varchar(MAX)=''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Location varchar(30)
SELECT @Location = @stepInput
IF NOT EXISTS(SELECT ID FROM Location WHERE Barcode = @Location)
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Location not in Granite'
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
