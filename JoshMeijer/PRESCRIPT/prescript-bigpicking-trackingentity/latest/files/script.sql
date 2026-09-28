CREATE PROCEDURE [dbo].[Prescript_BigPicking_TrackingEntity] (
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
@MasterItemCode varchar(100)
,@MasterItemID bigint
,@PickLocation varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'PickLocation')
,@LinkReference varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
,@TrackingEntity varchar(100) = @stepInput
,@TrackingEntityERPLocation varchar(30)
,@TrackingEntityID bigint
BEGIN TRY
	SELECT 
	@TrackingEntityID = TE.ID,
	@TrackingEntityERPLocation = L.ERPLocation,
	@MasterItemID = MI.ID,
	@MasterItemCode = MI.Code
	FROM TrackingEntity TE INNER JOIN [Location] L ON TE.Location_id = L.ID
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TE.Barcode = @TrackingEntity
	IF ISNULL(@TrackingEntityID, 0) = 0
	BEGIN
		RAISERROR('Barcode %s Not Found', 16, 1, @TrackingEntity)
	END
	IF NOT EXISTS(
	SELECT DD.ID FROM DocumentDetail DD
	INNER JOIN Document D ON DD.Document_id = D.ID
	WHERE DD.Item_id = @MasterItemID
	AND D.[Type] = 'ORDER'
	AND D.[Status] <> 'CANCELLED'
	AND D.RouteName = @LinkReference
	AND DD.Completed = 0
	AND DD.Cancelled = 0
	AND DD.FromLocation = @TrackingEntityERPLocation
	AND DD.Qty <> DD.ActionQty)
	BEGIN
		RAISERROR(N'Item %s Not Found On Link Reference %s For Location %s', 16, 1, @MasterItemCode, @LinkReference, @TrackingEntityERPLocation)
	END
	SELECT
	@valid = 1,
	@stepInput = @TrackingEntity
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