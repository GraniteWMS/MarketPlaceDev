CREATE PROCEDURE [dbo].[Prescript_Replenish_ToTrackingEntity] (
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
DECLARE @ToTrackingEntityLocation_id bigint = (SELECT Location_id FROM TrackingEntity WHERE Barcode = @stepInput)
DECLARE @LocationBarcode varchar(30) = (SELECT Barcode FROM [Location] WHERE ID = @ToTrackingEntityLocation_id)
IF NOT EXISTS(SELECT 1 FROM TrackingEntity WHERE Barcode = @stepInput)
BEGIN
	SELECT @valid = 0
	,@message = 'ERROR: Scan a valid TrackingEntity'
END
ELSE
	INSERT INTO @Output
	SELECT 'Location', @LocationBarcode
	SELECT @valid = 1
	,@message = ''
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
