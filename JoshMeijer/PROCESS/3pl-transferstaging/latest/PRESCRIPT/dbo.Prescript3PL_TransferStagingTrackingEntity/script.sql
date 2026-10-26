CREATE PROCEDURE [dbo].[Prescript3PL_TransferStagingTrackingEntity] (
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
DECLARE @Qty varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @TE_ID BIGINT 
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @Document_id BIGINT
SELECT @Document_id = ID FROM Document WHERE Number = @Document and [Type] = 'TRANSFER' and [Status] = 'RELEASED'
IF isnull(@Document_id,0) = 0
BEGIN
	SELECT @Valid = 0
	SELECT @message = 'This Transfer Document is Complete or not found'
END
ELSE 
BEGIN
	SELECT @TE_ID = ID, @Qty = Qty FROM TrackingEntity WHERE Barcode = @StepInput
	IF EXISTS(SELECT ID FROM [Transaction] WHERE TrackingEntity_id = @TE_ID and Document_id = @Document_id AND Type = 'TRANSFER')
	BEGIN
		SELECT @Valid = 0
		SELECT @Message = 'This pallet is already Transferred on this Document'
	END
	ELSE
	BEGIN
		SELECT @Valid = 1
		SELECT @Message = 'Pallet Transferred to Staging'
		INSERT INTO @Output
		SELECT 'Qty', @Qty
	END
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
