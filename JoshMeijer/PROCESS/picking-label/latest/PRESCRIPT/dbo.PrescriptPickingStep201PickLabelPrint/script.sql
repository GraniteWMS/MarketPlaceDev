CREATE PROCEDURE [dbo].[PrescriptPickingStep201PickLabelPrint] (
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
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput' )
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @Document varchar(30) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @TrackingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'TrackingEntity')
DECLARE @MasterItemCode varchar(50)
DECLARE @Qty varchar(50) = (SELECT Value FROM @input WHERE Name = 'Qty')
DECLARE @barcode nvarchar(50)
DECLARE @barcodes nvarchar(4000)
DECLARE @labelName nvarchar(500) = 'MasterItem.ZPL'
DECLARE @numberOfLabels int = CONVERT(int,@Qty)
DECLARE @printerName varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @type nvarchar(50) = 'MASTERITEM'
DECLARE @userID bigint = (SELECT ID FROM [Users] WHERE Name = @user)
DECLARE @success bit
BEGIN TRY
	SELECT @barcode = MI.Code
	FROM TrackingEntity TE
	INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
	WHERE TE.Barcode = @TrackingEntity
	EXECUTE [dbo].[clr_PrintLabel] 
	   @barcode
	  ,@barcodes
	  ,@labelName
	  ,@numberOfLabels
	  ,@printerName
	  ,@type
	  ,@userID
	  ,@success OUTPUT
	  ,@message OUTPUT
	  IF @success = 0
		RAISERROR(@message,16,1)
		SELECT	@Valid = 1,
				@Message = 'Labels printed'
		
END TRY
	
BEGIN CATCH
	SELECT @Valid = 1  
	SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
