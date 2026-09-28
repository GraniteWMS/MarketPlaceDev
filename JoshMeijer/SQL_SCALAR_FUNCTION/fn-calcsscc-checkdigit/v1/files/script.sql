CREATE FUNCTION [dbo].[FN_CalcSSCC_Checkdigit]
(
    @Barcode nvarchar(17)
)
RETURNS nvarchar(1)
AS
BEGIN
    DECLARE @i int = 1;
    DECLARE @len int;
    DECLARE @digit int;
    DECLARE @sum int = 0;
    DECLARE @checkdigit int;
    
    IF @Barcode IS NULL
        RETURN NULL;
    SET @Barcode = LTRIM(RTRIM(@Barcode));
    SET @len = LEN(@Barcode);
    IF @len <> 17 OR @Barcode LIKE '%[^0-9]%'
        RETURN NULL;
    
    WHILE @i <= @len
    BEGIN
        SET @digit = CAST(SUBSTRING(@Barcode, @len - @i + 1, 1) AS int);
        
        IF (@i % 2 = 1)
            SET @sum = @sum + (@digit * 3);
        ELSE
            SET @sum = @sum + @digit;
        SET @i = @i + 1;
    END
    SET @checkdigit = (10 - (@sum % 10)) % 10;
    RETURN CONVERT(nvarchar(1), @checkdigit);
END
