CREATE PROCEDURE [dbo].[PrescriptTransferDocument] (
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
DECLARE @Documentid BIGINT,
		@DocStatus varchar(30),
		@DocType varchar(30),
		@ERPLocation varchar(30),
		@Site varchar(30),
		@DestinationERPLocation varchar(30)
BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM Document WHERE Number = @stepInput AND [Type] IN ('TRANSFER', 'INTRANSIT'))
		RAISERROR('The Document %s does not Exist as a Transfer Document',16,1,@stepInput)
	SELECT @Documentid = ID, @DocStatus = [Status], @DocType = [Type], @ERPLocation = ERPLocation, @Site = [Site]
	FROM Document WHERE Number = @stepInput
	SELECT TOP 1 @DestinationERPLocation = TOLocation FROM DocumentDetail WHERE Document_id = @Documentid
	
	
	IF @DocStatus NOT IN ('ENTERED', 'RELEASED')
		RAISERROR('The Document %s is not in STatus ENTERED or RELEASED',16,1,@stepInput)
	IF @DocStatus = 'ENTERED' 
		UPDATE Document SET [Status] = 'RELEASED' WHERE Number = @stepInput
	EXEC dbo.FIFOPickingRecommendation @stepInput
	INSERT INTO @Output
	SELECT 'DestinationLocation', @DestinationERPLocation
	SELECT @valid = 1
	SELECT @message = 'Picking TRANSFER to Location:' + isnull(@DestinationERPLocation,'')
END Try
BEGIN CATCH
	SELECT @Valid = 0, 
	@message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
