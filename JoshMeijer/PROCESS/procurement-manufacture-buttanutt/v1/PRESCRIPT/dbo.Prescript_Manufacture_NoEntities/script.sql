CREATE PROCEDURE [dbo].[Prescript_Manufacture_NoEntities] (
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
DECLARE 
@DocumentID bigint = (SELECT ID FROM Document WHERE Number = (SELECT [Value] FROM @input WHERE [Name] = 'Document')),
@Batch varchar(100),
@ExpiryDate datetime,
@ExpiryDateAsString varchar(8)
SELECT TOP 1
@Batch = Batch,
@ExpiryDate = ExpiryDate
FROM DocumentDetail
WHERE Document_id = @DocumentID
AND [Type] = 'OUTPUT'
SET @ExpiryDateAsString = TRY_CONVERT(VARCHAR(8), CONVERT(DATE, @ExpiryDate, 103), 112)
BEGIN TRY
	INSERT INTO @Output
	SELECT 'Batch', @Batch
	UNION ALL
	SELECT 'ExpiryDate', @ExpiryDateAsString
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
