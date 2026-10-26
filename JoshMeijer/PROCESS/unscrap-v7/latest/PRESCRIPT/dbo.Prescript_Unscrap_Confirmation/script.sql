CREATE PROCEDURE [dbo].[Prescript_Unscrap_Confirmation] (
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
DECLARE 
@CurrentDateTime datetime = GETDATE(),
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = (SELECT [Value] FROM @input WHERE [Name] = 'User')),
@TrackingEntity varchar(100) = (SELECT [Value] FROM @input WHERE [Name] = 'MasterItem'),
@MasterItemID bigint,
@Qty decimal(19, 4),
@TrackingEntityID bigint,
@LocationID bigint;
SELECT
@MasterItemID = MI.ID,
@LocationID = L.ID,
@TrackingEntityID = TE.ID,
@Qty = TE.Qty
FROM TrackingEntity TE
INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
INNER JOIN [Location] L ON TE.Location_id = L.ID
WHERE TE.Barcode = @TrackingEntity AND TE.InStock = 0;
BEGIN TRY
	IF ISNULL(@stepInput, '') = 'YES'
	BEGIN
		IF ISNULL(@TrackingEntityID, 0) = 0
		BEGIN
			RAISERROR('Cannot find scrapped barcode %s', 16, 1, @TrackingEntity);
		END;
		INSERT INTO [dbo].[Transaction]
			   ([Date]
			   ,[FromQty]
			   ,[ToQty]
			   ,[ActionQty]
			   ,[DocumentDetailQty]
			   ,[FromDocumentDetailQty]
			   ,[ToDocumentDetailQty]
			   ,[UOM]
			   ,[UOMConversion]
			   ,[DocumentReference]
			   ,[Comment]
			   ,[IntegrationStatus]
			   ,[IntegrationReady]
			   ,[IntegrationDate]
			   ,[IntegrationReference]
			   ,[FromValue]
			   ,[ToValue]
			   ,[TrackingEntity_id]
			   ,[FromContainableEntity_id]
			   ,[ToContainableEntity_id]
			   ,[FromTrackingEntity_id]
			   ,[User_id]
			   ,[FromLocation_id]
			   ,[ToLocation_id]
			   ,[FromMasterItem_id]
			   ,[ToMasterItem_id]
			   ,[Document_id]
			   ,[DocumentLine_id]
			   ,[OptionalField_id]
			   ,[Type]
			   ,[Process]
			   ,[ActivityCost]
			   ,[ReversalTransaction_id]
			   ,[LinkedTransaction_id])
				SELECT
				@CurrentDateTime
			   ,@Qty
			   ,@Qty
			   ,@Qty
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,0
			   ,NULL
			   ,NULL
			   ,0
			   ,0
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@TrackingEntityID
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@UserID
			   ,NULL
			   ,@LocationID
			   ,@MasterItemID
			   ,NULL
			   ,NULL
			   ,NULL
			   ,NULL
			   ,'CUSTOM'
			   ,'UNSCRAP'
			   ,0
			   ,0
			   ,0;
		UPDATE dbo.TrackingEntity
		SET InStock = 1
		WHERE ID = @TrackingEntityID;
		SELECT 
		@valid = 1,
		@message = CONCAT('Unscrapped barcode ', @TrackingEntity, ' successfully');
	END
	ELSE
	BEGIN
		SELECT @valid = 1, @message = '';
	END;
END TRY
BEGIN CATCH
	SELECT 
	@valid = 0,
	@message = ERROR_MESSAGE();
END CATCH
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
