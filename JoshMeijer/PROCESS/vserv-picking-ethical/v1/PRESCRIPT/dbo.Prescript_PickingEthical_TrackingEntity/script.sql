CREATE PROCEDURE [dbo].[Prescript_PickingEthical_TrackingEntity] (
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
SELECT @stepInput = UPPER(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE 
@PCrate varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Comment')
,@EthicalPackingLocationID bigint = (SELECT ID FROM [Location] WHERE Barcode = 'ETHICAL PACKING')
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'CLOSE PICKING CRATE'
	BEGIN
		IF NOT EXISTS(SELECT * FROM Custom_VW_Ethical_PickingQuantitiesNotPacked WHERE PCrate = @PCrate) 
		BEGIN
			RAISERROR('No stock has been picked on crate %s', 16, 1, @PCrate)
		END
		UPDATE CarryingEntity
		SET Location_id = @EthicalPackingLocationID
		WHERE Barcode = @PCrate
		RAISERROR('Picking crate %s has been closed and moved to ETHICAL PACKING', 16, 1, @PCrate)
	END
	IF ISNULL(@stepInput, '') NOT LIKE 'ETHL%'
	BEGIN
		RAISERROR('Must be a Ethical (ETHL) barcode', 16, 1)
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
