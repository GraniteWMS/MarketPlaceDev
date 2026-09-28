CREATE PROCEDURE [dbo].[Prescript_Picking_Step200] (
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
DECLARE @Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
BEGIN TRY
	UPDATE DD
	SET DD.[Instruction] = IIF(ISNULL(RecommendedPickFace.[Location], '') = '', 
	'No Stock Found', 
	CONCAT('Barcode: ', RecommendedPickFace.[Barcode], ' - Location: ', RecommendedPickFace.[Location], ' - Created: ', RecommendedPickFace.CreatedDate, ' - Qty: ', CONVERT(BIGINT, RecommendedPickFace.Qty))
	)
	FROM DocumentDetail DD
	INNER JOIN Document D ON DD.Document_id = D.ID
	OUTER APPLY
	(SELECT TOP 1 TE.Barcode, L.Barcode AS [Location], CONVERT(VARCHAR, TE.CreatedDate, 111) AS CreatedDate, TE.Qty
	FROM TrackingEntity TE INNER JOIN [Location] L ON TE.Location_id = L.ID
	WHERE TE.InStock = 1 AND TE.Qty > 0 AND L.[Type] = 'BIN' AND TE.MasterItem_id = DD.Item_id
	ORDER BY TE.CreatedDate DESC) RecommendedPickFace
	WHERE D.Number = @Document
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