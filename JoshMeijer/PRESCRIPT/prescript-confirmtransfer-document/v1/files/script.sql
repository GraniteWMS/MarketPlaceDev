CREATE PROCEDURE [dbo].[Prescript_ConfirmTransfer_Document] (
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
DECLARE @DestinationLocation varchar(50) = 
(SELECT TOP 1 DD.ToLocation 
FROM DocumentDetail DD INNER JOIN Document D
ON DD.Document_id = D.ID
WHERE D.Number = @stepInput)
BEGIN TRY
	INSERT INTO @Output
	SELECT 'Location', @DestinationLocation
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
