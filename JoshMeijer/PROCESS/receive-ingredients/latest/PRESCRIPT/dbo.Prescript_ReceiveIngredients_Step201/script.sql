CREATE PROCEDURE [dbo].[Prescript_ReceiveIngredients_Step201] (
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
DECLARE @UserID bigint
DECLARE @User varchar(MAX) 
SELECT @User = Value FROM @input WHERE Name = 'User' 
SELECT @UserID = ID FROM [Users] WHERE Name = @User
DECLARE @LabelFormat varchar(50) = 'RECEIPTCONFIRM.ZPL'
DECLARE @Printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @Document varchar(50)
SELECT @Document = Value FROM @input WHERE Name = 'OptionalFieldValue0'
INSERT INTO LabelPrintQueue (DateQueued, LabelFormat, LabelParameter1, QuantityofLabels, Printer, [Status], [User])
SELECT getdate(),@LabelFormat, @Document,1,@Printer,'ENTERED',@User
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
