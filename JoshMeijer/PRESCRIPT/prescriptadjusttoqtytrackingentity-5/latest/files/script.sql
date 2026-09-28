CREATE PROCEDURE [dbo].[PrescriptAdjustToQtyTrackingEntity] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)  =''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @TrackingEntityInstock bit
BEGIN TRY
	IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
		RAISERROR('The Tracking Entity %s is not found',16,1,@stepInput)
	SELECT @TrackingEntityInstock = InStock
	FROM TrackingEntity
	WHERE Barcode = @stepInput
	IF @TrackingEntityInstock = 0
		RAISERROR('The Tracking Entity %s is not in stock',16,1,@stepInput)
	
	SELECT @Valid = 1
END TRY
BEGIN CATCH
	SELECT @valid = 0
	SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
