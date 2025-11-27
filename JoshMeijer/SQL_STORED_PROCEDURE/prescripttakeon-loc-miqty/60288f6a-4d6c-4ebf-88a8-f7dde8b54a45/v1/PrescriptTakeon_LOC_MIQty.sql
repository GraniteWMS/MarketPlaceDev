CREATE PROCEDURE [dbo].[PrescriptTakeon_LOC_MIQty] (
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

DECLARE @LocationBarcode varchar (30)
DECLARE @MasterItemCode varchar (40)
DECLARE @TrackingEntityBarcode varchar (50)

SELECT @LocationBarcode = Value FROM @input WHERE Name = 'Location' 
SELECT @MasterItemCode = Value FROM @input WHERE Name = 'MasterItem'
SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode, '_', @MasterItemCode)

SELECT @valid = 1
SELECT @message = ''

INSERT INTO @Output
SELECT 'UseBarcode', @TrackingEntityBarcode

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
