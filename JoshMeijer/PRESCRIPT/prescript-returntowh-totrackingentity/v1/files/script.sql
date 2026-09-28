CREATE PROCEDURE [dbo].[Prescript_ReturnToWH_ToTrackingEntity] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max), 
  Value varchar(max)
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
DECLARE @userName nvarchar(max) = (SELECT Value FROM @input WHERE Name = 'User')
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @FromTrackingEntityBarcode varchar(50) 
DECLARE @FromLocationBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'FromLocation')
DECLARE @TrackingEntityBarcode varchar (50)
DECLARE @LocationBarcode varchar (30) = (SELECT Value FROM @input WHERE Name = 'Location' )
DECLARE @MasterItemCode varchar (40)
DECLARE @MasterItem_id bigint
BEGIN TRY
    
    IF isnull(@FromLocationBarcode,'') = ''
        SELECT @FromLocationBarcode = 'STORES'
 
    IF EXISTS (SELECT 1 FROM dbo.MasterItem WHERE Code = @stepInput AND isActive = 1)
        SET @MasterItemCode = @stepInput;
    ELSE
    BEGIN
        IF LEN(@stepInput) = 13 AND EXISTS(SELECT 1 FROM dbo.MasterItem WHERE Code = LEFT(@stepInput,12))
        BEGIN
            SET @MasterItemCode = LEFT(@stepInput,12)
            SELECT @stepInput = LEFT(@stepInput,12)
        END
        ELSE
        BEGIN
            IF LEN(@stepInput) = 8 AND EXISTS(SELECT 1 FROM dbo.MasterItem WHERE Code = CONCAT('21000',LEFT(@stepInput,7)))
            BEGIN
                SET @MasterItemCode = CONCAT('21000',LEFT(@stepInput,7))
                SELECT @stepInput = CONCAT('21000',LEFT(@stepInput,7))
            END
            ELSE
            BEGIN
                DECLARE @aliasCount int = 0, @aliasCode varchar(100) = NULL;
                SELECT @aliasCount = COUNT(*),
                        @aliasCode  = MAX(MI.Code)
                FROM MasterItemAlias_View MIAV
                JOIN dbo.MasterItem      MI ON MIAV.MasterItem_id = MI.ID
                WHERE MIAV.Code = @stepInput  or (CHARINDEX(MIAV.Code,@stepInput,1)>0 AND LEN(MIAV.Code)>10)
                    AND MI.isActive = 1;
                IF @aliasCount = 0
                    RAISERROR('(%s) is not a valid item code or known alias.', 16, 1, @stepInput);
                IF @aliasCount > 1
                    RAISERROR('Scanned code "%s" maps to multiple items. Please scan the item code.', 16, 1, @stepInput);
                SET @MasterItemCode = @aliasCode;
            END
        END
    END
	SELECT @TrackingEntityBarcode = CONCAT(@LocationBarcode, '_', @MasterItemCode)
    SELECT @FromTrackingEntityBarcode = CONCAT(@FromLocationBarcode, '_', @MasterItemCode)
    INSERT INTO @Output
    SELECT 'FromTrackingEntity',@FromTrackingEntityBarcode
    IF NOT EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @FromTrackingEntityBarcode AND Qty>0)
    BEGIN
        DECLARE @trackingEntityIdentifier nvarchar(max) = @FromTrackingEntityBarcode
        DECLARE @locationIdentifier nvarchar(max)=  @FromLocationBarcode
        DECLARE @masterItemIdentifier nvarchar(max) = @MasterItemCode
        DECLARE @uom nvarchar(max) = NULL
        DECLARE @packSize int = ''
        DECLARE @qty numeric(19,4) = 1
        DECLARE @carryingEntityIdentifier nvarchar(max) =NULL
        DECLARE @batch nvarchar(max) = NULL
        DECLARE @serialNumber nvarchar(max) = NULL
        DECLARE @expiryDate datetime = NULL
        DECLARE @manufactureDate datetime = NULL
        DECLARE @numberOfEntities int = 1
        DECLARE @comment nvarchar(max) = 'No FROM TE so Create in Store Location'
        DECLARE @reference nvarchar(max) = NULL
        DECLARE @integrationReference nvarchar(max) = NULL
        DECLARE @processName nvarchar(max) = 'RETURNTOWH'
        DECLARE @success bit
        DECLARE @barcodes nvarchar(max)
        
        EXECUTE [dbo].[clr_Takeon] 
           @userName
          ,@trackingEntityIdentifier
          ,@locationIdentifier
          ,@masterItemIdentifier
          ,@uom
          ,@packSize
          ,@qty
          ,@carryingEntityIdentifier
          ,@batch
          ,@serialNumber
          ,@expiryDate
          ,@manufactureDate
          ,@numberOfEntities
          ,@comment
          ,@reference
          ,@integrationReference
          ,@processName
          ,@success OUTPUT
          ,@message OUTPUT
          ,@barcodes OUTPUT
        IF @success <> 1
		        RAISERROR('Error in Takeon -cannot create the New record:%s, ERROR:%s',16,1,@TrackingEntityBarcode, @message)
    END
	SELECT @valid = 1
	SELECT @message = @TrackingEntityBarcode
	SELECT @stepInput =  @TrackingEntityBarcode
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()  
END CATCH
 
INSERT INTO @Output (Name, Value)
VALUES
    ('Message',  @message),
    ('Valid',    CONVERT(varchar(10), @valid)),
    ('StepInput',@stepInput);
SELECT * FROM @Output
