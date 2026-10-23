CREATE PROCEDURE [dbo].[Prescript_BigPicking_Qty] (
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
DECLARE @TrackingEntity varchar(100) = (SELECT Value FROM @input WHERE Name = 'TrackingEntity')
DECLARE @TrackingEntityQty decimal(19, 4) = (SELECT Qty FROM TrackingEntity WHERE Barcode = @TrackingEntity)
,@QtyToPick decimal(19, 4) = CONVERT(DECIMAL(19, 4), @stepInput)
BEGIN TRY
	IF @QtyToPick > @TrackingEntityQty
	BEGIN	
		SELECT @message = CONCAT('You are trying to pick ', @QtyToPick, ' but there is only ', @TrackingEntityQty, ' on barcode ', @TrackingEntity)
		RAISERROR(@message, 16, 1)
	END
		
	SELECT
	@valid = 1,
	@message = @stepInput
END TRY
BEGIN CATCH
	SELECT
	@valid = 0,
	@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
