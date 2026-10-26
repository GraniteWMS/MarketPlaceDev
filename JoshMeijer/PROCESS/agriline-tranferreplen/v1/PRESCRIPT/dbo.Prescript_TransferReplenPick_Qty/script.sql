CREATE PROCEDURE [dbo].[Prescript_TransferReplenPick_Qty] (
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
DECLARE @LocationBarcode varchar(50) = 'REPLENISHSTAGING'
DECLARE @FromTrackingEntityBarcode varchar(50) =  (SELECT TRIM(Value) FROM @input WHERE Name = 'TrackingEntity')
DECLARE @FromLocationBarcode varchar(50) = (SELECT TRIM(Value) FROM @input WHERE Name = 'FromLocation')
DECLARE @ToTrackingEntity varchar(50)
DECLARE @MasterItemCode varchar(50)
BEGIN TRY
	SELECT @MasterItemCode = MI.Code 
	FROM TrackingEntity TE INNER JOIN MasterITem MI
	ON TE.MasterItem_id = MI.ID
	WHERE TE.Barcode = @FromTrackingEntityBarcode
	SELECT @ToTrackingEntity = CONCAT(@LocationBarcode,'_',@MasterItemCode)
    INSERT INTO @Output
    SELECT 'UseBarcode', @ToTrackingEntity
    IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @FromTrackingEntityBarcode AND Qty>0)
        RAISERROR('There is no stock of %s in the location %s to Putaway',16,1,@MasterItemCode,@FromLocationBarcode)
   
	SELECT @valid = 1
	,@message = 'Moving into Location: ' + @LocationBarcode
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()  
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
