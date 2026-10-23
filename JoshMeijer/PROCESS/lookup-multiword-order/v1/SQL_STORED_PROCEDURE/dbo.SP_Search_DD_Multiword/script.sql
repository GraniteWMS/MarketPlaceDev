CREATE PROCEDURE [dbo].[SP_Search_DD_Multiword]
    @Search NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX) = '
        SELECT MasterItem.Code,
			   Document.Number,
			   Document.TradingPartnerCode AS Customer,
			   CAST((DocumentDetail.Qty-DocumentDetail.ActionQty) AS decimal(19,0)) AS Qty,
			   --CONVERT(VARCHAR,DocumentDetail.ExpiryDate,103) ExpiryDate,
               MasterItem.Description
        FROM [DocumentDetail]
		LEFT JOIN [MasterItem] on DocumentDetail.Item_id = MasterItem.ID
		LEFT JOIN [Document] ON Document_id = Document.ID
		WHERE DocumentDetail.Cancelled = 0 AND DocumentDetail.Completed = 0
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
        SET @sql = @sql + ' AND MasterItem.Description LIKE ''%' + @Word + '%''';
        FETCH NEXT FROM cur INTO @Word;
    END;
    CLOSE cur;
    DEALLOCATE cur;
    SET @sql = @sql + ' ORDER BY Number;';
    EXEC sp_executesql @sql;
END;
