CREATE PROCEDURE [dbo].[Prescript_REPRINTBOXLABEL_Confirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @BoxNumber varchar(30) = (SELECT Value FROM @input WHERE Name = 'Box')
DECLARE @userName nvarchar(max) = (SELECT Value FROM @input WHERE Name = 'User')
BEGIN TRY
	IF @stepInput NOT in ('Y','YES','Yes')
	BEGIN
		SELECT @Valid = 1, @message = 'Cancelled'		
	END
	ELSE
	BEGIN
		IF NOT Exists(SELECT ID FROM CarryingEntity WHERE Barcode = @BoxNumber)
			RAISERROR('The entered or scanned box %s does not exist as a PACKED box',16,1,@BoxNumber)
		INSERT INTO LabelPrintQueue (DateQueued,LabelFormat,LabelParameter1,QuantityofLabels,Printer,[Status],[User])
		SELECT getdate(),'SSRSBoxLabel',@BoxNumber,1,'Z4','ENTERED',@userName
		SELECT @Valid = 1
		SELECT @Message = 'Box Label queued to printer'
	END
END TRY
BEGIN CATCH
	SELECT @Valid = 0, @Message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
