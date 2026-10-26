CREATE PROCEDURE [dbo].[Prescript_PickingEthical_Step200] (
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
@UseFIFO bit = (IIF(ISNULL((SELECT [Value] FROM SystemStaticData WHERE [Key] = 'ActivateFIFO'), 'No') = 'Yes', 1, 0))
,@UseFEFO bit = (IIF(ISNULL((SELECT [Value] FROM SystemStaticData WHERE [Key] = 'ActivateFEFO'), 'No') = 'Yes', 1, 0))
,@Document varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Document')
BEGIN TRY
	IF @UseFEFO = 1
	BEGIN
		UPDATE DD
		SET DD.[Instruction] = IIF(ISNULL(RecommendedPickFace.[Location], '') = '', 
		'No Stock Found', 
		CONCAT(IIF(RecommendedPickFace.EthicalBox IS NULL, 'LOOSE STOCK', CONCAT('Box: ', RecommendedPickFace.EthicalBox)), ' - Location: ', RecommendedPickFace.[Location], ' - Expiry: ', RecommendedPickFace.ExpiryDate, ' - Qty: ', CONVERT(BIGINT, RecommendedPickFace.Qty))
		)
		FROM DocumentDetail DD
		INNER JOIN Document D ON DD.Document_id = D.ID
		OUTER APPLY
		(SELECT TOP 1 L.Barcode AS [Location], CONVERT(VARCHAR, TE.ExpiryDate, 111) AS ExpiryDate, TE.Qty, CE.Barcode AS EthicalBox
		FROM TrackingEntity TE INNER JOIN [Location] L ON TE.Location_id = L.ID
		LEFT JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
		WHERE TE.InStock = 1 AND TE.Qty > 0 AND L.[Type] = 'ETHL_PICKFACE' AND TE.MasterItem_id = DD.Item_id
		ORDER BY TE.ExpiryDate ASC) RecommendedPickFace
		WHERE D.Number = @Document
	END
	ELSE IF @UseFIFO = 1
	BEGIN
		UPDATE DD
		SET DD.[Instruction] = IIF(ISNULL(RecommendedPickFace.[Location], '') = '', 
		'No Stock Found', 
		CONCAT(IIF(RecommendedPickFace.EthicalBox IS NULL, 'LOOSE STOCK', CONCAT('Box: ', RecommendedPickFace.EthicalBox)), ' - Location: ', RecommendedPickFace.[Location], ' - Created: ', RecommendedPickFace.CreatedDate, ' - Qty: ', CONVERT(BIGINT, RecommendedPickFace.Qty))
		)
		FROM DocumentDetail DD
		INNER JOIN Document D ON DD.Document_id = D.ID
		OUTER APPLY
		(SELECT TOP 1 L.Barcode AS [Location], CONVERT(VARCHAR, TE.CreatedDate, 111) AS CreatedDate, TE.Qty, CE.Barcode AS EthicalBox
		FROM TrackingEntity TE INNER JOIN [Location] L ON TE.Location_id = L.ID
		LEFT JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
		WHERE TE.InStock = 1 AND TE.Qty > 0 AND L.[Type] = 'ETHL_PICKFACE' AND TE.MasterItem_id = DD.Item_id
		ORDER BY TE.CreatedDate DESC) RecommendedPickFace
		WHERE D.Number = @Document
	END
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
