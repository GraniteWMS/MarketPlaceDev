CREATE PROCEDURE [dbo].[PrescriptCreatePickslipPickslip]
    (
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
DECLARE @stepInput varchar(50) = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @user varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @printer varchar(50) = (SELECT Value FROM @input WHERE Name = 'PrinterName')
DECLARE @PickslipID BIGINT
DECLARE @Pickslip varchar(30)
IF UPPER(@stepInput) = 'NEW'
BEGIN
    SELECT @Pickslip =  Prefix + CONVERT(varchar(30),NextBarcode) FROM BarcodeMaster
    WHERE Name = 'PICKING'
    UPDATE BarcodeMaster SET NextBarcode =  NextBarcode + 1 WHERE Name = 'PICKING'
    SELECT @stepInput = @Pickslip
    SELECT @message = 'New pickslip number created:' +  @pickslip
END
IF SUBSTRING(@stepInput,1,2) <> 'PS'
BEGIN
	SELECT @message = 'You must use the PICKSLIP number or click NEW - not the an order number -that comes next'
	SELECT @valid = 0
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT *
FROM @Output
