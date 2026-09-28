CREATE PROCEDURE [dbo].[PrescriptAssignDeliveryNotePickSlip] (
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
DECLARE 
    @Prefix VARCHAR(20),
    @Length INT,
    @NextBarcode BIGINT,
    @NextDocumentNumber VARCHAR(50),
    @AuditUser VARCHAR(50), 
    @Now DATETIME = GETDATE(),
    @Location VARCHAR(30),
    @ERPLocation VARCHAR(30);
SELECT @Location = Value
FROM @input
WHERE Name = 'Location'
SELECT @ERPLocation = ERPLocation
FROM Location
WHERE Barcode = @Location
IF @stepInput = 'ADD'
BEGIN
    
    
    
    SELECT 
        @Prefix = Prefix,
        @Length = [Length],
        @NextBarcode = NextBarcode
    FROM dbo.BarcodeMaster WITH (UPDLOCK, ROWLOCK)
    WHERE [Name] = 'DOCUMENTOUTBOUND';
    SELECT @AuditUser = Value FROM @input WHERE Name = 'User';
    IF @NextBarcode IS NULL
    BEGIN
        RAISERROR('BarcodeMaster entry for DOCUMENTOUTBOUND not found.', 16, 1);
        RETURN;
    END;
    
    
    
    SET @NextDocumentNumber = CONCAT(@Prefix,(replicate('0', @Length - len(@NextBarcode)) + cast (@NextBarcode as varchar)));
    
    
    
    INSERT INTO dbo.[Document]
    (
        [Number],
        [Type],
        [Status],
        [TradingPartnerCode],
        [TradingPartnerDescription],
        [Description],
        [ActionDate],
        [CreateDate],
        [ExpectedDate],
        [isActive],
        [Priority],
        [ERPLocation],
        [Site],
        [RouteName],
        [StopName],
        [AssignedTo],
        [ERPIdentification],
        [AuditDate],
        [AuditUser],
        [Version],
        [ERPSyncFailed],
        [ERPSyncFailedReason]
    )
    VALUES
    (
        @NextDocumentNumber,              
        'PICKSLIP',                      
        'RELEASED',                       
        NULL,                             
        NULL,                             
        'Auto-created PICKSLIP Document',
        @Now,                             
        @Now,                             
        NULL,                             
        1,                                
        0,	                              
        @ERPLocation,                     
        '',								  
        NULL,                             
        NULL,                             
        NULL,                             
        NULL,                             
        @Now,                             
        @AuditUser,                       
        1,                                
        0,                                
        NULL                              
    );
    
    
    
    UPDATE dbo.BarcodeMaster
    SET NextBarcode = @NextBarcode + 1
    WHERE [Name] = 'DOCUMENTOUTBOUND';
    
    
    
    SELECT @valid = 1
    SELECT @message = CONCAT('Document ', @NextDocumentNumber, ' successfully created')
    SELECT @stepInput = @NextDocumentNumber
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
