CREATE PROCEDURE [dbo].[PrescriptLOCATION_ITEM_BARCODE_PICKMasterItem] (
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

DECLARE @TrackingEntityBarcode varchar (50)
DECLARE @MasterItem_id bigint
DECLARE @MasterItemCode varchar (40)

SELECT @MasterItemCode = @stepInput

IF EXISTS(SELECT ID FROM MasterItem WHERE Code = @MasterItemCode AND isActive = 1)
BEGIN

	SELECT @valid = 1
	SELECT @message = ''

END
ELSE
BEGIN

	SELECT @valid = 0
	SELECT @message = CONCAT(@MasterItemCode, ' does not exist')

END

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
