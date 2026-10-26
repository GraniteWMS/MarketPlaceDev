CREATE PROCEDURE [dbo].[Prescript_Picking_FromLocation] (
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
SELECT @stepInput = TRIM(Value) FROM @input WHERE Name = 'StepInput' 
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @LocationIdentifier varchar (50)
DECLARE @Exists bit
DECLARE @LocationBarcode varchar (50)
DECLARE @LPReset bit = 0
DECLARE @CurrentDocumentDetail_id bigint
DECLARE @LocationZone varchar(10) = (SELECT Value FROM @input WHERE Name = 'LocationZone')
BEGIN TRY
IF @stepInput = 'SKIP'
BEGIN
	SELECT TOP 1 @CurrentDocumentDetail_id = DD.ID
	FROM Document D
	INNER JOIN DocumentDetail DD ON D.ID=DD.Document_id
	WHERE D.Number=@Document
	AND ISNULL(DD.Instruction,'')<>'NO STOCK AVAILABLE'
	AND ISNULL(DD.ActionQty,0)<DD.Qty
	AND (
		ISNULL(@LocationZone,'')=''
		OR DD.Instruction LIKE 'ZONE '+@LocationZone+'|%'
		OR	(
			DD.Instruction NOT LIKE 'ZONE %|%'
			AND @LocationZone='UNASSIGNED'
			)
		)
	ORDER BY DD.LinePriority
	UPDATE DocumentDetail SET LinePriority = '99999'
	FROM Document D INNER JOIN DocumentDetail DD ON D.ID = DD.Document_id		
	WHERE D.Number = @Document and DD.ID = @CurrentDocumentDetail_id
	EXEC dbo.FIFOPickingRecommendation @Document = @stepInput, @LPReset = @LPReset
	SELECT @valid = 0, @message = 'ITEM SKIPPED'
END
ELSE
BEGIN
	SELECT @LocationIdentifier = UPPER(@stepInput)
	EXEC dbo.ValidateLocation @LocationIdentifier,
							  @Exists OUTPUT, 
							  @LocationBarcode OUTPUT
	IF @Exists = 0
		RAISERROR('Location %s does not exist or is inactive',16,1,@LocationIdentifier)
	SELECT	@valid = 1 ,@stepInput = @LocationBarcode
END
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()  
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
