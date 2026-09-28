CREATE FUNCTION dbo.GetJulianDate
(
    @InputDate DATE
)
RETURNS VARCHAR(7)
AS
BEGIN
    DECLARE @JulianDate VARCHAR(7)
    SET @JulianDate = 
        RIGHT('000' + CAST(DATEPART(DAYOFYEAR, @InputDate) AS VARCHAR), 3) + '/' +
        RIGHT('00' + CAST(YEAR(@InputDate) % 100 AS VARCHAR), 2)
    RETURN @JulianDate
END
