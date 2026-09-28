CREATE PROCEDURE [dbo].[Prescript_Dispatch_CarryingEntity] (
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
@CarryingEntity varchar(50) = @stepInput,
@CurrentDateTime datetime = GETDATE(),
@UserID bigint = (SELECT ID FROM Users WHERE [Name] = (SELECT [Value] FROM @input WHERE [Name] = 'User')),
@CarryingEntityLocationID bigint,
@CarryingEntityID bigint,
@DispatchLocationID bigint = (SELECT ID FROM [Location] WHERE [Barcode] = 'DISPATCH'),
@VehicleRegistration varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Comment'),
@DriverName varchar(50) = (SELECT [Value] FROM @input WHERE [Name] = 'Reference')
SELECT 
@CarryingEntityID = ID,
@CarryingEntityLocationID = Location_id
FROM CarryingEntity
WHERE Barcode = @CarryingEntity
BEGIN TRY
	IF ISNULL(@CarryingEntityID, 0) = 0
	BEGIN
		RAISERROR('Cannot find barcode %s', 16, 1, @stepInput)
	END
	IF @CarryingEntityLocationID = @DispatchLocationID
	BEGIN
		RAISERROR('Barcode %s is already in DISPATCH', 16, 1, @CarryingEntity)
	END
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
           ,TE.Qty
           ,TE.Qty
           ,TE.Qty
           ,TE.Qty
           ,0
           ,TE.Qty
           ,NULL
           ,0
           ,@DriverName
           ,@VehicleRegistration
           ,0
           ,0
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,TE.ID
           ,TE.BelongsToEntity_id
           ,TE.BelongsToEntity_id
           ,NULL
           ,@UserID
           ,@CarryingEntityLocationID
           ,@DispatchLocationID
           ,TE.MasterItem_id
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,'CUSTOM'
           ,'DISPATCH'
           ,0
           ,0
           ,0
           FROM TrackingEntity TE 
		   WHERE BelongsToEntity_id = @CarryingEntityID
           UPDATE TrackingEntity
		   SET Location_id = @DispatchLocationID
		   WHERE BelongsToEntity_id = @CarryingEntityID
		   UPDATE CarryingEntity
		   SET Location_id = @DispatchLocationID
		   WHERE ID = @CarryingEntityID
	SELECT 
	@valid = 1,
	@message = CONCAT('Barcode ', @CarryingEntity, ' moved to DISPATCH')
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
