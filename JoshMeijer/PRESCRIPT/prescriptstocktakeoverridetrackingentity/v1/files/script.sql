CREATE PROCEDURE [dbo].[PrescriptStocktakeOverrideTrackingEntity] (
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
DECLARE 
      @PalletBarcode varchar(50)
    , @PalletID bigint
    , @ScannedTrackingEntityID bigint
    , @BelongsToID bigint
    , @SessionInput varchar(MAX)
    , @CountInput varchar(MAX)
    , @StockTakeSessionID bigint
    , @CountNo int;
SELECT @PalletBarcode = [Value]
FROM @input
WHERE [Name] = 'CustomPallet';
SELECT @SessionInput = [Value]
FROM @input
WHERE [Name] = 'Session';
SELECT @CountInput = [Value]
FROM @input
WHERE [Name] = 'Count';
SET @CountNo =
    CASE 
        WHEN @CountInput IN ('1', '2', '3') THEN CAST(@CountInput AS int)
        ELSE NULL
    END;
IF ISNULL(@PalletBarcode, '') = ''
BEGIN
    SET @valid = 0;
    SET @message = 'No pallet barcode was selected.';
    GOTO Finish;
END;
SELECT TOP (1)
    @PalletID = CE.ID
FROM dbo.CarryingEntity CE WITH (NOLOCK)
WHERE CE.Barcode = @PalletBarcode
ORDER BY CE.ID DESC;
IF @PalletID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Pallet ', @PalletBarcode, ' could not be found.');
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
    SET @valid = 0;
    SET @message = 'Stocktake session could not be found or is not active.';
    GOTO Finish;
END;
IF @CountNo IS NULL
BEGIN
    SET @valid = 0;
    SET @message = 'Invalid stocktake count. Count must be 1, 2 or 3.';
    GOTO Finish;
END;
SELECT TOP (1)
      @ScannedTrackingEntityID = TE.ID
    , @BelongsToID = TE.BelongsToEntity_id
FROM dbo.TrackingEntity TE WITH (NOLOCK)
WHERE TE.Barcode = @stepInput
  AND ISNULL(TE.InStock, 0) = 1
ORDER BY TE.ID DESC;
IF @ScannedTrackingEntityID IS NULL
BEGIN
    SET @valid = 0;
    SET @message = CONCAT('Barcode ', @stepInput, ' could not be found or is not in stock.');
    GOTO Finish;
END;
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
IF ISNULL(@BelongsToID, 0) = 0
BEGIN
    UPDATE dbo.TrackingEntity
    SET BelongsToEntity_id = @PalletID
    WHERE ID = @ScannedTrackingEntityID
      AND ISNULL(BelongsToEntity_id, 0) = 0;
    SET @message = CONCAT('Barcode ', @stepInput, ' linked to pallet ', @PalletBarcode, '.');
END
ELSE
BEGIN
    SET @message = CONCAT('Barcode ', @stepInput, ' is already linked to a pallet.');
END;
Finish:
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output