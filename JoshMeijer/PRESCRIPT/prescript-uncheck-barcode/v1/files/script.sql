CREATE PROCEDURE [dbo].[Prescript_Uncheck_Barcode] (
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
SET @valid = 1
SET @message = @stepInput
DECLARE @DocumentNumber varchar(50)
DECLARE @UncheckType varchar(30)
DECLARE @DocumentID bigint
SELECT @DocumentNumber = Value FROM @input WHERE Name = 'Document'
SELECT @UncheckType = Value FROM @input WHERE Name = 'Type'
SELECT @DocumentID = ID FROM Document WHERE Number = @DocumentNumber
IF @UncheckType = 'MASTERITEM'
BEGIN
	IF NOT EXISTS(SELECT ID FROM DocumentDetail WHERE Document_id = @DocumentID AND Item_id = (SELECT ID FROM MasterItem WHERE Code = @stepInput))
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' is not on ', @DocumentNumber)
	END
END
IF @UncheckType = 'SERIALNUMBER'
BEGIN
	IF NOT EXISTS(SELECT T.ID FROM [Transaction] T INNER JOIN TrackingEntity TE ON T.TrackingEntity_id = TE.ID WHERE T.Document_id = @DocumentID AND TE.SerialNumber = @stepInput AND ISNULL(T.ReversalTransaction_id, 0) = 0 AND T.[Type] = 'PACK')
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' is not on ', @DocumentNumber)
	END
END
IF @UncheckType = 'TRACKINGENTITY'
BEGIN
	IF NOT EXISTS(SELECT T.ID FROM [Transaction] T WHERE T.Document_id = @DocumentID AND T.Comment = @stepInput AND ISNULL(T.ReversalTransaction_id, 0) = 0 AND T.[Type] = 'PACK')
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' is not on ', @DocumentNumber)
	END
END
IF @UncheckType = 'PALLET'
BEGIN
	IF NOT EXISTS(SELECT T.ID FROM [Transaction] T WHERE T.Document_id = @DocumentID AND T.Comment = @stepInput AND ISNULL(T.ReversalTransaction_id, 0) = 0 AND T.[Type] = 'PACK')
	BEGIN
		SET @valid = 0
		SET @message = CONCAT(@stepInput, ' is not on ', @DocumentNumber)
	END
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
