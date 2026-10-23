CREATE PROCEDURE [dbo].[GetLookupDataSimple]
    @value NVARCHAR(100)
AS
BEGIN
	
	DECLARE @MasterItemCode varchar(50)
	DECLARE @FirstSpace int
 	
	SELECT @FirstSpace = Charindex(' ',@value,0)
	IF @FirstSpace > 0
		SELECT @value = LEFT(@value,@Firstspace-1)
	SELECT @MasterItemCode = @value
	IF EXISTS (SELECT 1 FROM dbo.MasterItem WHERE Code = @value AND isActive = 1)
        SET @MasterItemCode = @value;
    ELSE
    BEGIN
        IF LEN(@value) = 13 AND EXISTS(SELECT 1 FROM dbo.MasterItem WHERE Code = LEFT(@value,12))
        BEGIN
            SET @MasterItemCode = LEFT(@value,12)
            SELECT @value = LEFT(@value,12)
        END
        ELSE
        BEGIN
            DECLARE @aliasCount int = 0, @aliasCode varchar(100) = NULL;
            SELECT @aliasCount = COUNT(*),
                    @aliasCode  = MAX(MI.Code)
            FROM MasterItemAlias_View MIAV
            JOIN dbo.MasterItem      MI ON MIAV.MasterItem_id = MI.ID
            WHERE MIAV.Code = @value 
                AND MI.isActive = 1;
            SET @MasterItemCode = @aliasCode;
        END
    END
	IF EXISTS(SELECT ID FROM Location WHERE Barcode = @value)		 
		SELECT TE.Barcode as TrackingEntity_Barcode, TE.Qty As TrackingEntity_Qty, 
		MI.Description AS MasterItem_Description, MI.Code as MasterItem_Code, 
		L.Barcode as Location_Barcode
		FROM TrackingEntity TE 
		INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
		INNER JOIN Location L ON TE.Location_id = L.ID
		WHERE L.Barcode= @value
	ELSE
		SELECT TE.Barcode as TrackingEntity_Barcode, TE.Qty As TrackingEntity_Qty, 
		MI.Description AS MasterItem_Description, MI.Code as MasterItem_Code, 
		L.Barcode as Location_Barcode
		FROM TrackingEntity TE 
		INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID
		INNER JOIN Location L ON TE.Location_id = L.ID
		WHERE MI.Code= @MasterItemCode
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    
END
