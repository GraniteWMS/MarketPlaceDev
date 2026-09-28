CREATE PROCEDURE [dbo].[Prescript_Packing_CarryingEntity] (
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
DECLARE @UserName varchar(20) = (SELECT [Value] FROM @input WHERE [Name] = 'User')
DECLARE @Document varchar(30) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
DECLARE @Document_id bigint = (SELECT ID FROM Document WHERE Number = @Document)
DECLARE @ExistingCarryingEntiy varchar(30) = (SELECT TOP 1 CarryingEntityBarcode FROM Custom_CarryingEntityAllocation WHERE Document_id = @Document_id ORDER BY ID DESC)
DECLARE @DocumentIncrement bigint = (SELECT NextBarcode FROM BarcodeMaster WHERE [Name] = 'DOCUMENTCARRYINENTITY')
DECLARE @NewCarryingEntity varchar(50)
BEGIN TRY
	IF @stepInput = 'Continue packing'
	BEGIN
		SELECT @stepInput = @ExistingCarryingEntiy
	END
	ELSE
	BEGIN
		SELECT @NewCarryingEntity = CONCAT(@Document, '_', @DocumentIncrement)
		INSERT INTO Custom_CarryingEntityAllocation([User], Document_id, DocumentNumber, CarryingEntityBarcode)
		VALUES(@UserName, @Document_id, @Document, @NewCarryingEntity)
		SELECT @stepInput = @NewCarryingEntity
		UPDATE BarcodeMaster
		SET NextBarcode = @DocumentIncrement + 1
		WHERE [Name] = 'DOCUMENTCARRYINENTITY'
	END
	SELECT @valid = 1
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
