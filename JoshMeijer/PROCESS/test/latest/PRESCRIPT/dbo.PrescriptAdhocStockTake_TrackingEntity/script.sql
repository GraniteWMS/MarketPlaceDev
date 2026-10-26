CREATE PROCEDURE [dbo].[PrescriptAdhocStockTake_TrackingEntity] (
    @input dbo.ScriptInputParameters READONLY 
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Output TABLE(
        Name VARCHAR(MAX), 
        Value VARCHAR(MAX)
    )
    DECLARE @valid BIT = 0
    DECLARE @message VARCHAR(MAX) = ''
    DECLARE @stepInput VARCHAR(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput')
    DECLARE @StockTakeSession_id BIGINT = (SELECT ID FROM StockTakeSession WHERE [Name] = (SELECT Value FROM @input WHERE [Name] = 'Session'))
    DECLARE @Count VARCHAR(5) = (SELECT Value FROM @input WHERE [Name] = 'Count')
    IF EXISTS(SELECT ID FROM TrackingEntity WHERE Barcode = @stepInput)
    BEGIN
        DECLARE @TrackingEntity_id BIGINT
        DECLARE @Location_id BIGINT
        DECLARE @Location_erp VARCHAR(15)
        DECLARE @MasterItem_Code VARCHAR(40)
        DECLARE @TrackingEntity_qty DECIMAL(19,4)
        DECLARE @InStock BIT
        SELECT @TrackingEntity_id = TE.ID, @InStock = InStock, @Location_id = Location_id, @Location_erp = L.ERPLocation,
               @MasterItem_Code = MI.Code, @TrackingEntity_qty = Qty
        FROM TrackingEntity TE
        INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
        INNER JOIN [Location] L ON TE.Location_id = L.ID
        WHERE TE.Barcode = @stepInput
        IF @InStock = 1
        BEGIN
            IF NOT EXISTS(SELECT 1 FROM StockTakeLines WHERE StockTakeSession_id = @StockTakeSession_id AND TrackingEntity_id = @TrackingEntity_id)
            BEGIN
                INSERT INTO StockTakeLines ([StockTakeSession_id], [Barcode], [MasterItemCode], [OpeningLocationERP], [OpeningLocation_id], [OpeningQty], [Status], [MasterItem_id], [TrackingEntity_id])
                VALUES (@StockTakeSession_id, @stepInput, @MasterItem_Code, @Location_erp, @Location_id, @TrackingEntity_qty, 'OUTSTANDING', (SELECT MasterItem_id FROM TrackingEntity WHERE ID = @TrackingEntity_id), @TrackingEntity_id)
                SET @valid = 1
                SET @message = CONCAT('Barcode ', @stepInput, ' added to session')
            END
            ELSE
            BEGIN
                
                SET @valid = 1
            END
        END
        ELSE
        BEGIN
            SET @message = CONCAT('Barcode ', @stepInput, ' is not in stock')
        END
    END
    
    ELSE
    BEGIN
        SET @valid = 1
    END
    INSERT INTO @Output (Name, Value) VALUES ('Message', @message), ('Valid', @valid), ('StepInput', @stepInput)
    SELECT * FROM @Output
END
