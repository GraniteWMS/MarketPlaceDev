CREATE PROCEDURE [dbo].[PrescriptAddEANBarcodeConfirmation] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 0
DECLARE @message varchar(MAX) = 'Could not capture barcode'
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @MasterItem varchar(50)
DECLARE @MasterItemID bigint = 0
DECLARE @User varchar(50)
DECLARE @ERPIdentification varchar(50)
DECLARE @EANBarcode varchar(50)
SELECT @MasterItem = LTRIM(RTRIM(Value)) 
FROM @input 
WHERE Name = 'MasterItem'
IF ISNULL(@MasterItem, '') = ''
BEGIN
    SELECT @MasterItem = LTRIM(RTRIM(Value)) 
    FROM @input 
    WHERE Name = 'MasterItemCode'
END
SELECT @User = LTRIM(RTRIM(Value)) 
FROM @input 
WHERE Name = 'User'
SELECT @EANBarcode = LTRIM(RTRIM(Value)) 
FROM @input 
WHERE Name = 'EANBarcode'
IF ISNULL(@EANBarcode, '') = ''
BEGIN
    SELECT @EANBarcode = LTRIM(RTRIM(Value)) 
    FROM @input 
    WHERE Name = 'AliasBarcode'
END
SELECT TOP (1) 
      @MasterItemID = ID
    , @ERPIdentification = ERPIdentification 
FROM dbo.MasterItem WITH (NOLOCK)
WHERE Code = @MasterItem
IF UPPER(LTRIM(RTRIM(ISNULL(@stepInput, '')))) = 'YES'
BEGIN
    BEGIN TRY
        INSERT INTO dbo.MasterItemAlias 
        (
              Code
            , UOM
            , IsActive
            , AuditDate
            , AuditUser
            , MasterItem_id
            , [Version]
            , ERPIdentification
        )
        VALUES 
        (
              @EANBarcode
            , 'Each'
            , 1
            , GETDATE()
            , @User
            , @MasterItemID
            , CONVERT(smallint, 0)
            , @ERPIdentification
        )
    
        SELECT @valid = 1
        SELECT @message = 'Barcode Captured'
    END TRY
    BEGIN CATCH
        SELECT @valid = 0
        SELECT @message = 'Something went wrong: ' + ERROR_MESSAGE()
    END CATCH
END
ELSE
BEGIN
    SELECT @valid = 0
    SELECT @message = 'Barcode was not confirmed'
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output