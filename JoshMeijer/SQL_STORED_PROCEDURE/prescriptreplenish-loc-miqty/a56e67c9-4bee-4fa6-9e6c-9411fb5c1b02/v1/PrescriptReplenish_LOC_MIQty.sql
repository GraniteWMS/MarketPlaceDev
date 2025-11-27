CREATE PROCEDURE [dbo].[PrescriptReplenish_LOC_MIQty] (
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
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput'

DECLARE @ToLocationBarcode varchar (30)
DECLARE @FromTrackingEntity varchar (50)
DECLARE @MasterItemCode varchar (40)
DECLARE @ToTrackingEntityBarcode varchar (50)

SELECT @ToLocationBarcode = Value FROM @input WHERE Name = 'Location' 
SELECT @FromTrackingEntity = Value FROM @input WHERE Name = 'FromTrackingEntity'
SELECT @MasterItemCode = MI.Code FROM MasterItem MI INNER JOIN
						 TrackingEntity TE ON MI.ID = TE.MasterItem_id
						 WHERE TE.Barcode = @FromTrackingEntity
SELECT @ToTrackingEntityBarcode = CONCAT(@ToLocationBarcode, '_', @MasterItemCode)

INSERT INTO @Output
SELECT 'ToTrackingEntity', @ToTrackingEntityBarcode

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
