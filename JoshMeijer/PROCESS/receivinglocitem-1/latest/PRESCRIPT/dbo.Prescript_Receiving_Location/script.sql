CREATE PROCEDURE [dbo].[Prescript_Receiving_Location] (
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
DECLARE @LocationBarcode varchar(50) = @stepInput
SELECT @LocationBarcode = Barcode FROM [Location] WHERE Barcode = @StepInput OR Name = @StepInput
SELECT @stepInput = @LocationBarcode
SELECT @valid = 1
SELECT @message = ''
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
