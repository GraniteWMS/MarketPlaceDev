CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_QtyPerBox] (
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
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @NumberOfBoxes bigint = (SELECT Value FROM @input WHERE Name = 'NoOfBoxes')
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput') 
DECLARE @Document varchar(50) = (SELECT UPPER(Value) FROM @input WHERE Name = 'Document') 
DECLARE @MasterItemCode varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @MasterItemUOMConversion decimal(19, 4)
DECLARE @QtyPerBox decimal(19, 4)
DECLARE @QtyToPack decimal(19, 4)
DECLARE @TotalQtyConverted decimal(19, 4)
DECLARE @TotalQty decimal(19, 4)
DECLARE @QtyAlreadyPacked decimal(19, 4)
DECLARE @QtyForItemOnDocument decimal(19, 4)
IF @MasterItemCode IN (SELECT Code FROM MasterItemAlias_View)
BEGIN
	SELECT TOP 1 @MasterItemUOMConversion = MIAV.Conversion, @MasterItemCode = MI.Code FROM MasterItemAlias_View MIAV
	INNER JOIN MasterItem MI ON MIAV.MasterItem_id = MI.ID
	WHERE MIAV.Code = @MasterItemCode
END
SET @MasterItemUOMConversion = ISNULL(@MasterItemUOMConversion, 1)
SET @QtyPerBox = CAST(@stepInput AS decimal(19, 4))
SET @TotalQty = @QtyPerBox * @NumberOfBoxes
SET @TotalQtyConverted = @TotalQty * @MasterItemUOMConversion
SELECT @QtyToPack = SUM(DD.Qty), @QtyAlreadyPacked = SUM(DD.PackedQty) FROM DocumentDetail DD
INNER JOIN Document D ON DD.Document_id = D.ID INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
WHERE D.Number = @Document AND MI.Code = @MasterItemCode
IF @TotalQtyConverted < = (@QtyToPack - @QtyAlreadyPacked)
BEGIN
	SET @valid = 1
	SET @message = CONCAT('Total Quantity To Pack: ', @TotalQtyConverted)
	SET @stepInput = @stepInput
END
ELSE
BEGIN
	SET @valid = 0
	SET @message = CONCAT(@TotalQtyConverted, ' is more than what is on ', @Document, ' for item ', @MasterItemCode)
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
