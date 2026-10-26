CREATE PROCEDURE  [dbo].[Prescript_PrintMasterItemLabels_NumberOfLabels] (
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
DECLARE @sQty varchar(20)
BEGIN TRY
	SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
	SELECT @sQty = @stepInput
	IF isnumeric(@sQty) = 0
		RAISERROR('The Qty of Labels to print must be Numeric',16,1)
	IF TRY_CONVERT(INT,@sQty) > 99
		RAISERROR('The Qty of Labels to print must be less than 100',16,1)
	SELECT @message = CONCAT('Qty to print:',@sQty)
	SELECT @valid = 1
	
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
