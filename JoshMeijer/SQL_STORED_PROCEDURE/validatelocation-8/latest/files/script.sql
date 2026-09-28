CREATE PROCEDURE [dbo].[ValidateLocation]
(
    @LocationIdentifier  varchar(50),
    @Exists              bit           OUTPUT,
    @LocationBarcode     varchar(50)   OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @Exists = 0;
    SET @LocationBarcode = NULL;
    
    SET @LocationIdentifier = LTRIM(RTRIM(@LocationIdentifier));
    IF @LocationIdentifier IS NULL OR @LocationIdentifier = ''
        RETURN;
    BEGIN TRY
        
        SELECT TOP (1)
               @LocationBarcode = L.Barcode
        FROM dbo.[Location] AS L
        WHERE L.isActive = 1
          AND (L.[Name] = @LocationIdentifier OR L.Barcode = @LocationIdentifier)
        ORDER BY CASE WHEN L.Barcode = @LocationIdentifier THEN 0 ELSE 1 END,
                 L.ID;  
        IF @LocationBarcode IS NOT NULL
            SET @Exists = 1;
    END TRY
    BEGIN CATCH
        
        SET @Exists = 0;
        SET @LocationBarcode = NULL;
        THROW;
    END CATCH
END
