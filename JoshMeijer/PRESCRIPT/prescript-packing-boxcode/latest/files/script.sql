CREATE PROCEDURE [dbo].[Prescript_Packing_BoxCode] (
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
DECLARE @Location varchar(50) = (SELECT Value FROM @input WHERE Name = 'Location')
DECLARE @BoxNumber varchar(30) = (SELECT Value FROM @input WHERE Name = 'CarryingEntity')
DECLARE @TrackingEntityBarcode varchar(100)
DECLARE @MasterItemCode VARCHAR(50) 
DECLARE @userName nvarchar(max) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @FirstSpace int
BEGIN TRY
	IF(@stepInput != '')
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM MasterItem WHERE Code = @stepInput AND [Type] = 'PACKAGING')
			RAISERROR('ERROR: %s is not a valid box.', 16, 1, @stepInput)
		IF @stepInput = 'CUSTOM'
		BEGIN
			UPDATE CarryingEntity
			SET type_id = MasterItem.ID
			FROM MasterItem WHERE Code = @stepInput
			AND CarryingEntity.Barcode = @BoxNumber
		END
		ELSE
		BEGIN
			UPDATE CarryingEntity
			SET [type_id] = MasterItem.ID,
				[Length] = CAST(MasterItem.[Length] AS decimal(19,3))/10,
				[Width] = CAST(MasterItem.[Width] AS decimal(19,3))/10,
				[Height] = CAST(MasterItem.[Height] AS decimal(19,3))/10
			FROM MasterItem WHERE Code = @stepInput
			AND CarryingEntity.Barcode = @BoxNumber
		END
	END
END TRY
BEGIN CATCH
	SELECT @Valid = 0
	,@Message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
