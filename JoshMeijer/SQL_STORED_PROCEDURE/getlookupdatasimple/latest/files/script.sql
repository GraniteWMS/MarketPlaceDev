CREATE PROCEDURE [dbo].[GetLookupDataSimple]
@value NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MasterItemCode varchar(50);
    DECLARE @FirstSpace int;
    SELECT @FirstSpace = CHARINDEX(' ', @value, 0);
    IF @FirstSpace > 0
        SELECT @value = LEFT(@value, @FirstSpace - 1);
    SELECT @MasterItemCode = @value;
    IF EXISTS (SELECT 1 FROM dbo.MasterItem WHERE Code = @value AND isActive = 1)
        SET @MasterItemCode = @value;
    ELSE
    BEGIN
        IF LEN(@value) = 13 
           AND EXISTS (SELECT 1 FROM dbo.MasterItem WHERE Code = LEFT(@value, 12))
        BEGIN
            SET @MasterItemCode = LEFT(@value, 12);
            SELECT @value = LEFT(@value, 12);
        END
        ELSE
        BEGIN
            DECLARE @aliasCode varchar(100) = NULL;
            SELECT @aliasCode = MAX(MI.Code)
            FROM MasterItemAlias_View MIAV
            INNER JOIN dbo.MasterItem MI 
                ON MIAV.MasterItem_id = MI.ID
            WHERE MIAV.Code = @value 
              AND MI.isActive = 1;
            SET @MasterItemCode = @aliasCode;
        END
    END;
    IF EXISTS (SELECT 1 FROM Location WHERE Barcode = @value)
    BEGIN
        SELECT  
            L.Category AS Zone,
            L.Barcode AS Bin,
            MI.Code AS ItemCode, 
            CONVERT(int, TE.Qty) AS Qty, 
            MI.Description AS [Description]
        FROM TrackingEntity TE 
        INNER JOIN MasterItem MI 
            ON TE.MasterItem_id = MI.ID
        INNER JOIN Location L 
            ON TE.Location_id = L.ID
        WHERE L.Barcode = @value
          AND TE.InStock = 1
          AND L.NonStock = 0
        ORDER BY 
			TE.Qty DESC,
            L.Category,
            L.Barcode,
            MI.Code;
    END
    ELSE
    BEGIN
        SELECT 
            L.Category AS Zone,
            L.Barcode AS Bin,
            MI.Code AS ItemCode,
            CONVERT(int, TE.Qty) AS Qty, 
            MI.Description AS [Description]
        FROM TrackingEntity TE 
        INNER JOIN MasterItem MI 
            ON TE.MasterItem_id = MI.ID
        INNER JOIN Location L 
            ON TE.Location_id = L.ID
        WHERE MI.Code = @MasterItemCode
          AND TE.InStock = 1
          AND L.NonStock = 0
        ORDER BY 
			TE.Qty DESC,
            L.Category,
            L.Barcode;
    END
END
