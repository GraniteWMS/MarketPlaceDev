CREATE PROCEDURE [dbo].[Prescript_Checking_Document] (
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
DECLARE @User varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @CurrentDate datetime = GETDATE()
IF NOT EXISTS(SELECT ID FROM CarryingEntity WHERE Barcode = @stepInput)
BEGIN
	INSERT INTO CarryingEntity(Barcode, CreateDate, [Location_id], AuditDate, AuditUser)
	SELECT @stepInput, @CurrentDate, ID, @CurrentDate, @User FROM [Location] WHERE Barcode = 'DIS'
END
SET @valid = 1
SET @message = CONCAT('Using Document: ', @stepInput)
	INSERT INTO @Output
	SELECT 'CarryingEntity', @stepInput
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
