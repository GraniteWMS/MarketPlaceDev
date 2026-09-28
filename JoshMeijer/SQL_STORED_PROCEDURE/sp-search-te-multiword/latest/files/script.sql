CREATE PROCEDURE [dbo].[SP_Search_TE_Multiword]
    @Search NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX) = '
        SELECT MasterItem.Code,
			   TrackingEntity.Barcode,
			   Location.Name AS Location,
			   CAST(TrackingEntity.Qty AS decimal(19,0)) AS Qty,
			   CONVERT(VARCHAR,TrackingEntity.ExpiryDate,103) ExpiryDate,
               MasterItem.Description
        FROM MasterItem
		LEFT JOIN [TrackingEntity] on MasterItem.ID = TrackingEntity.MasterItem_id
		LEFT JOIN [Location] ON TrackingEntity.Location_id = Location.ID
		WHERE 1=1
    ';
    
    DECLARE @Word NVARCHAR(100);
    DECLARE cur CURSOR FOR
        SELECT LTRIM(RTRIM(value))
        FROM STRING_SPLIT(@Search, ' ')
        WHERE LTRIM(RTRIM(value)) <> '';
    OPEN cur;
    FETCH NEXT FROM cur INTO @Word;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = @sql + ' AND Description LIKE ''%' + @Word + '%''';
        FETCH NEXT FROM cur INTO @Word;
    END;
    CLOSE cur;
    DEALLOCATE cur;
    SET @sql = @sql + ' ORDER BY Description;';
    EXEC sp_executesql @sql;
END;
