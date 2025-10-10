CREATE PROCEDURE [dbo].[PrescriptReceivingPutawayQty] (
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




DECLARE @MasterItem varchar(50)
DECLARE @PutawayLocationID bigint
DECLARE @PutawayLocationBarcode varchar(50)

SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'MasterItem'
SELECT @PutawayLocationID = PutawayLocation_id FROM MasterItem WHERE Code = @MasterItem

IF ISNULL(@PutawayLocationID, 0) = 0
BEGIN
	SELECT @PutawayLocationID = PutawayLocation_id FROM MasterItem WHERE FormattedCode = @MasterItem
END

SELECT @PutawayLocationBarcode = Barcode FROM [Location] WHERE ID = @PutawayLocationID

INSERT INTO @Output
SELECT 'Location', @PutawayLocationBarcode

SELECT @valid = 1





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
