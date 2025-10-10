CREATE PROCEDURE [dbo].[PrescriptReceivingPutawayMasterItem] (
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

IF ISNULL(@PutawayLocationID, 0) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = 'No putaway location found for this MasterItem'
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
