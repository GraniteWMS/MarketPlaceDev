CREATE PROCEDURE [dbo].[Prescript_Transfer_Document] (
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
DECLARE @Document varchar(50) = @stepInput
DECLARE @DestinationLocation varchar(50)
DECLARE @UserName varchar(20) = (SELECT Value FROM @input WHERE Name = 'User')
BEGIN TRY
	IF EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput and [TYPE] = 'TRANSFER' AND [Status] = 'ENTERED')
		UPDATE Document SET [Status] = 'RELEASED', AssignedTo = @UserName
		WHERE Number = @stepInput
	SELECT TOP 1 @DestinationLocation = ToLocation 
	FROM Document D INNER JOIN DocumentDetail DD
	ON DD.Document_id = D.ID
	WHERE D.Number = @Document
	EXEC dbo.FIFOPickingRecommendation @stepInput
	SELECT @valid = 1
	SELECT @message = ''
	INSERT INTO @Output
	SELECT 'DestinationLocation',@DestinationLocation
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
