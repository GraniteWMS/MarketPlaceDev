CREATE PROCEDURE [dbo].[Prescript_PackMultipleBoxes_Step200] (
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
DECLARE @QtyPerBox decimal(19, 4) = (SELECT Value FROM @input WHERE Name = 'QtyPerBox')
DECLARE @LocationBarcode varchar(50) = 'WHSE'
DECLARE @CurrentBoxNumber varchar(50)
DECLARE @responseCode [int]
DECLARE	@responseJSON [nvarchar](max)
DECLARE @UserID bigint
DECLARE @Length bigint
DECLARE @NextBarcode bigint
DECLARE @Prefix varchar(10)
DECLARE @Min bigint
DECLARE @Max bigint
DECLARE @Counter bigint
SELECT @UserID = ID FROM Users WHERE [Name] = @user
SELECT @Length = [Length], @NextBarcode = [NextBarcode], @Prefix = [Prefix] FROM BarcodeMaster
WHERE [Name] = 'BOX'
UPDATE BarcodeMaster
SET NextBarcode = NextBarcode + @NumberOfBoxes
WHERE [Name] = 'BOX'
DECLARE @NewBoxes TABLE
(
ID bigint identity(1, 1),
BoxNumber varchar(50)
);
WITH Barcodes AS
(
SELECT 0 + @NextBarcode AS BarcodeNumber
UNION ALL
SELECT BarcodeNumber + 1 FROM Barcodes
WHERE BarcodeNumber < @NumberOfBoxes + @NextBarcode - 1
)
INSERT INTO @NewBoxes (BoxNumber)
SELECT CONCAT(@Prefix, REPLICATE('0', @Length - LEN(BarcodeNumber)), BarcodeNumber) FROM Barcodes
OPTION(MAXRECURSION 100)
INSERT INTO CarryingEntity (Barcode, CreateDate, Location_id, AuditUser, AuditDate)
SELECT BoxNumber, GETDATE(), (SELECT ID FROM [Location] WHERE Barcode = @LocationBarcode), @user, GETDATE() FROM @NewBoxes
SELECT @Min = MIN(ID), @Max = MAX(ID), @Counter = MIN(ID) FROM @NewBoxes
WHILE @Counter >= @Min AND @Counter <= @Max
BEGIN
	SELECT @CurrentBoxNumber = BoxNumber FROM @NewBoxes WHERE ID = @Counter
	EXEC [dbo].[clr_Pack]
	@Document,
	@LocationBarcode,
	@CurrentBoxNumber,
	@MasterItemCode,
	@QtyPerBox,
	@UserID,
	@MasterItemCode,
	'PACKING',
	'',
	'',
	@responseCode  OUTPUT,
	@responseJSON OUTPUT
	SET @Counter = @Counter + 1
END
SET @valid = 1
SELECT @message = STUFF((SELECT ' ' + RTRIM([BoxNumber]) FROM @NewBoxes FOR XML PATH(''),TYPE).value('(./text())[1]','varchar(MAX)'),1,1,'')
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
