CREATE Procedure [dbo].[Utility_PrintSSCCLabel]
	@Document varchar(50),
	@PalletBarcode varchar(50),
	@printerName varchar(50)
AS
BEGIN
	DECLARE @DocumentID bigint
		SELECT @DocumentID = ID FROM Document WHERE Number = @Document
	DECLARE @ERPLocation varchar(30)
		SELECT @ERPLocation = ERPLocation FROM Document WHERE ID = @DocumentID
	DECLARE @CarryingEntity varchar(30)
	
	
	IF (ISNULL(@DocumentID, 0) = 0) 
		RETURN;
	IF NOT EXISTS (SELECT 1 FROM CarryingEntity WHERE Barcode = @PalletBarcode)
		RETURN;
	DECLARE @userID bigint = 3
DECLARE @barcode nvarchar(max)  = @PalletBarcode
DECLARE @barcodes nvarchar(max) = NULL
DECLARE @type nvarchar(max) = 'BOX'
DECLARE @labelName nvarchar(max) 
SELECT @LabelName = [Value] FROM SystemStaticData WHERE [Group] = 'Labels' AND [Key] = 'CCF_SSCCLabelName'
DECLARE @numberOfLabels int 
SELECT @numberOfLabels = CONVERT(INT,[Value]) FROM SystemStaticData WHERE [Group] = 'Labels' AND [Key] = 'CCF_SSCCNumberofLabels'
DECLARE @success bit
DECLARE @message varchar(max)
EXEC dbo.clr_PrintLabel
	@barcode
	,@barcodes
	,@labelName
	,@numberOfLabels
	,@printerName
	,@type
	,@userID
	,@success
	,@message
END
