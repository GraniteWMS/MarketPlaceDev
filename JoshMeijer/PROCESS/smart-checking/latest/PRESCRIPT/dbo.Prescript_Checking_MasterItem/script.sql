CREATE PROCEDURE [dbo].[Prescript_Checking_MasterItem] (
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
DECLARE @Document varchar(50)
DECLARE @CheckType varchar(50)
DECLARE @CheckedQty decimal(19, 4)
DECLARE @NumberOfMasterItemsOnPallet bigint
DECLARE @MasterItemCode varchar(50)
SELECT @Document = UPPER(Value) FROM @input WHERE Name = 'Document'
SELECT @CheckType = Value FROM @input WHERE Name = 'Type'
IF @CheckType = 'TRACKINGENTITY'
BEGIN
	SELECT @CheckedQty = SUM(T.ActionQty) 
	FROM [Transaction] T 
	INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID 
	INNER JOIN Document D ON T.Document_id = D.ID
	WHERE D.Number = @Document
	AND TE.Barcode = @stepInput
	AND ISNULL(T.ReversalTransaction_id, 0) = 0
	IF ISNULL(@CheckedQty, 0) > 0
	BEGIN
		INSERT INTO @Output
		SELECT 'Comment', UPPER(@stepInput)
		SET @valid = 1
		SET @message = CONCAT(@stepInput, ' checked')
	END
	ELSE
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' not found on ', @Document)
	END
END
IF @CheckType = 'SERIALNUMBER'
BEGIN
	SELECT @CheckedQty = SUM(T.ActionQty) 
	FROM [Transaction] T 
	INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID 
	INNER JOIN Document D ON T.Document_id = D.ID
	WHERE D.Number = @Document
	AND TE.SerialNumber = @stepInput
	AND ISNULL(T.ReversalTransaction_id, 0) = 0
	IF ISNULL(@CheckedQty, 0) > 0
	BEGIN
		SELECT @stepInput = Barcode FROM TrackingEntity WHERE SerialNumber = @stepInput
		SET @valid = 1
		SET @message = CONCAT(@stepInput, ' checked')
	END
	ELSE
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' not found on ', @Document)
	END
END
IF @CheckType = 'PALLET'
BEGIN
	SELECT @NumberOfMasterItemsOnPallet = COUNT(DISTINCT MI.ID) 
	FROM CarryingEntity CE
	INNER JOIN TrackingEntity TE ON TE.BelongsToEntity_id = CE.ID
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE CE.Barcode = @stepInput
	IF @NumberOfMasterItemsOnPallet = 1
	BEGIN
		SELECT @CheckedQty = SUM(T.ActionQty) 
		FROM [Transaction] T 
		INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID
		INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
		INNER JOIN Document D ON T.Document_id = D.ID
		WHERE D.Number = @Document
		AND CE.Barcode = @stepInput
		AND ISNULL(T.ReversalTransaction_id, 0) = 0
		SELECT TOP 1 @MasterItemCode = MI.Code
		FROM CarryingEntity CE
		INNER JOIN TrackingEntity TE ON TE.BelongsToEntity_id = CE.ID
		INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
		WHERE CE.Barcode = @stepInput
		IF ISNULL(@CheckedQty, 0) > 0
		BEGIN
			INSERT INTO @Output
			SELECT 'Comment', UPPER(@stepInput)
			SET @stepInput = @MasterItemCode
			SET @valid = 1
			SET @message = CONCAT(@stepInput, ' checked')
		END
		ELSE
		BEGIN
			SET @valid = 0
			SET @message = CONCAT(@stepInput, ' not found on ', @Document)
		END
	END
	ELSE
	BEGIN
		SET @valid = 0
		SET @message = CONCAT('There is more than 1 item code on ', @stepInput)
	END
END
IF @CheckType = 'MASTERITEM'
BEGIN
	SELECT @CheckedQty = SUM(T.ActionQty) 
	FROM [Transaction] T 
	INNER JOIN MasterItem MI ON T.FromMasterItem_id = MI.ID
	INNER JOIN Document D ON T.Document_id = D.ID
	WHERE D.Number = @Document
	AND MI.Code = @stepInput
	AND ISNULL(T.ReversalTransaction_id, 0) = 0
	IF ISNULL(@CheckedQty, 0) > 0
	BEGIN
		SET @valid = 1
		SET @message = CONCAT(@stepInput, ' checked')
	END
	ELSE
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' not found on ', @Document)
	END
END
	INSERT INTO @Output
	SELECT 'CarryingEntity', @Document
	INSERT INTO @Output
	SELECT 'Qty', CAST(@CheckedQty AS BIGINT)
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
