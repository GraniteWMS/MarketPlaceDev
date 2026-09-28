CREATE PROCEDURE [dbo].[PrescriptStocktakeTrackingEntity] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @SessionInput varchar(MAX)
    , @CountInput varchar(MAX)
    , @LocationInput varchar(MAX)
    , @StockTakeSessionID bigint
    , @ScannedTrackingEntityID bigint
    , @BelongsToID bigint
    , @LocationID bigint
    , @UserID bigint
    , @User varchar(30)
    , @Now datetime = GETDATE()
    , @InsertedCount int = 0
    , @TrackingEntityQty decimal(19,4)
    , @PalletBarcode varchar(50)
    , @PalletID bigint
    , @CountNo int;
SELECT @stepInput = [Value]
FROM @input
WHERE [Name] = 'StepInput';
SELECT @SessionInput = [Value]
FROM @input
WHERE [Name] = 'Session';
SELECT @CountInput = [Value]
FROM @input
WHERE [Name] = 'Count';
SELECT @LocationInput = [Value]
FROM @input
WHERE [Name] = 'Location';
SELECT @User = [Value]
FROM @input
WHERE [Name] IN ('User');
SELECT @PalletBarcode = [Value]
FROM @input
WHERE [Name] IN ('CustomPallet');
SET @CountNo =
    CASE 
        WHEN @CountInput IN ('1', '2', '3') THEN CAST(@CountInput AS int)
        ELSE NULL
    END;
IF ISNULL(@SessionInput, '') NOT LIKE 'Daily%'
BEGIN
    GOTO Finish;
END;
SELECT TOP (1)
    @StockTakeSessionID = STS.ID
FROM dbo.StockTakeSession STS WITH (NOLOCK)
WHERE STS.[Name] = @SessionInput
  AND ISNULL(STS.Active, 0) = 1
ORDER BY STS.ID DESC;
IF @StockTakeSessionID IS NULL
BEGIN
    GOTO Finish;
END;
IF @CountNo IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Invalid stocktake count. Count must be 1, 2 or 3.';
    GOTO Finish;
END;
SELECT TOP (1)
    @PalletID = CE.ID
FROM dbo.CarryingEntity CE WITH (NOLOCK)
WHERE CE.Barcode = @PalletBarcode
ORDER BY CE.ID DESC;
IF ISNULL(@PalletBarcode, '') <> ''
   AND @PalletID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Pallet ', @PalletBarcode, ' could not be found.');
    GOTO Finish;
END;
SELECT TOP (1)
      @ScannedTrackingEntityID = TE.ID
    , @BelongsToID = TE.BelongsToEntity_id
    , @TrackingEntityQty = TE.Qty
FROM dbo.TrackingEntity TE WITH (NOLOCK)
WHERE TE.Barcode = @stepInput
  AND ISNULL(TE.InStock, 0) = 1
ORDER BY TE.ID DESC;
IF @ScannedTrackingEntityID IS NULL
BEGIN
    
    GOTO Finish;
END;
IF ISNULL(@BelongsToID, 0) = 0
   AND ISNULL(@PalletID, 0) <> 0
BEGIN
    UPDATE dbo.TrackingEntity
    SET BelongsToEntity_id = @PalletID
    WHERE ID = @ScannedTrackingEntityID
      AND ISNULL(BelongsToEntity_id, 0) = 0;
    SET @BelongsToID = @PalletID;
END;
SELECT TOP (1)
    @LocationID = L.ID
FROM dbo.[Location] L WITH (NOLOCK)
WHERE L.Barcode = @LocationInput
ORDER BY L.ID DESC;
IF EXISTS
(
    SELECT 1
    FROM dbo.StockTakeLines STL WITH (NOLOCK)
    WHERE STL.StockTakeSession_id = @StockTakeSessionID
      AND
      (
            STL.TrackingEntity_id = @ScannedTrackingEntityID
         OR STL.Barcode = @stepInput
      )
      AND
      (
            (@CountNo = 1 AND STL.Count1Qty IS NOT NULL)
         OR (@CountNo = 2 AND STL.Count2Qty IS NOT NULL)
         OR (@CountNo = 3 AND STL.Count3Qty IS NOT NULL)
      )
)
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Barcode ', @stepInput, ' has already been scanned for Count ', @CountNo, '.');
    GOTO Finish;
END;
;WITH BarcodesToAdd AS
(
    SELECT
          TE.ID AS TrackingEntity_id
        , TE.Barcode
        , TE.MasterItem_id
        , MI.Code AS MasterItemCode
        , TE.BelongsToEntity_id AS CarryingEntity_id
        , CE.Barcode AS CarryingEntityBarcode
        , ISNULL(TE.Location_id, @LocationID) AS OpeningLocation_id
        , L.ERPLocation AS OpeningLocationERP
        , TE.Qty AS OpeningQty
    FROM dbo.TrackingEntity TE WITH (NOLOCK)
    LEFT JOIN dbo.MasterItem MI WITH (NOLOCK)
        ON MI.ID = TE.MasterItem_id
    LEFT JOIN dbo.CarryingEntity CE WITH (NOLOCK)
        ON CE.ID = TE.BelongsToEntity_id
    LEFT JOIN dbo.[Location] L WITH (NOLOCK)
        ON L.ID = ISNULL(TE.Location_id, @LocationID)
    WHERE ISNULL(TE.InStock, 0) = 1
      AND
      (
            
            (
                ISNULL(@BelongsToID, 0) = 0
                AND TE.ID = @ScannedTrackingEntityID
            )
            OR
            
            (
                ISNULL(@BelongsToID, 0) <> 0
                AND TE.BelongsToEntity_id = @BelongsToID
            )
      )
)
INSERT INTO dbo.StockTakeLines
(
      StockTakeSession_id
    , Barcode
    , MasterItemCode
    , CarryingEntityBarcode
    , OpeningLocationERP
    , OpeningLocation_id
    , OpeningQty
    , [Status]
    , Scans
    , LastScanDate
    , Count1Qty
    , Count2Qty
    , Count3Qty
    , ApprovedQty
    , Count1User_id
    , Count2User_id
    , Count3User_id
    , Location_id
    , Scrap
    , MasterItem_id
    , TrackingEntity_id
    , CarryingEntity_id
)
SELECT
      @StockTakeSessionID
    , BTA.Barcode
    , BTA.MasterItemCode
    , BTA.CarryingEntityBarcode
    , BTA.OpeningLocationERP
    , BTA.OpeningLocation_id
    , BTA.OpeningQty
    , 'OUTSTANDING'
    , 0
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , @LocationID
    , 0
    , BTA.MasterItem_id
    , BTA.TrackingEntity_id
    , BTA.CarryingEntity_id
FROM BarcodesToAdd BTA
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.StockTakeLines STL WITH (NOLOCK)
    WHERE STL.StockTakeSession_id = @StockTakeSessionID
      AND
      (
            STL.TrackingEntity_id = BTA.TrackingEntity_id
         OR STL.Barcode = BTA.Barcode
      )
);
SET @InsertedCount = @@ROWCOUNT;
IF @InsertedCount > 0
BEGIN
    SET @message = CONCAT(@InsertedCount, ' barcode(s) added to daily stocktake.');
END;
Finish:
INSERT INTO @Output
SELECT 'Qty', ISNULL(@TrackingEntityQty, 0)
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output