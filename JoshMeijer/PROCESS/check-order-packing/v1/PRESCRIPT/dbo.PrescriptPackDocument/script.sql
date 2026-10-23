
CREATE PROCEDURE [dbo].[PrescriptPackDocument] (
   @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )

SET NOCOUNT ON;

DECLARE @sql varchar(max)
DECLARE @html varchar(max)
DECLARE @orderby varchar(max)

DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT UPPER(Value) FROM @input WHERE Name = 'StepInput') 
DECLARE @sOrderNumber varchar(50) = RTRIM(@stepInput)




DECLARE	@return_value int = 0











DECLARE @Document_id BIGINT
SELECT @Document_id = ID FROM Document WHERE Number = @sOrderNumber

IF isnull(@Document_id,0) > 0
BEGIN
	
	INSERT INTO custom_DocumentTrackingLog (Document,[Version],TrackingStatus,[User],ActivityDate,Comment)
	SELECT @sOrderNumber,1,'START CHECKING',@User,getdate(),'Starting Checking and Packing Process'
	UPDATE Document SET [Status] = 'CHECKING' WHERE ID = @Document_id
	INSERT INTO LabelPrintQueue(DateQueued,LabelFormat,LabelParameter1,QuantityofLabels,Printer,Status,[User])
	SELECT getdate(), 'SHIPLABEL.BTW', @sOrderNumber, '5','ZSHIP', 'ENTERED', @user


	
	
	UPDATE DocumentDetail SET ActionQty = Qty WHERE Document_id = @Document_id and isnull(ActionQty,0) = 0
	EXEC [dbo].Logic_PackingInstruction @stepInput


	






	IF Exists(select CE.Barcode as ShipPallet, SUM(TE.Qty) as PackedQty
		from [Transaction] TX 
		INNER JOIN TrackingEntity TE ON TX.TrackingEntity_id = TE.ID
		INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
		WHERE Document_id =  @Document_id  and [Type] = 'PACK' 
		GROUP BY CE.Barcode)
	BEGIN
		SELECT @sql = CONCAT('select CE.Barcode as ShipPallet, SUM(TE.Qty) as PackedQty , ''LightYellow'' as RowColor
		from [Transaction] TX 
		INNER JOIN TrackingEntity TE ON TX.TrackingEntity_id = TE.ID
		INNER JOIN CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
		WHERE Document_id = ', @Document_id ,' and [Type] = ''PACK'' 
		GROUP BY CE.Barcode
		')

		SELECT @OrderBy = 'ORDER BY ShipPallet'


		EXEC dbo.SqlToHtml @sql, @OrderBy, @html OUTPUT
	
	
		INSERT INTO @Output
		SELECT 'Instruction', @html
END

END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'The Order Document is not in Granite- Check Distribution One and Try again'
END



INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output

