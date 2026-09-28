
CREATE FUNCTION GenerateJulianDateCode
(
	@currentDate datetime
)
RETURNS varchar(5)
AS
BEGIN
	DECLARE @JulianDateCode varchar(5)
	SELECT @JulianDateCode = 
	RIGHT('000' + CONVERT(varchar(3), DATEPART(DAYOFYEAR, GETDATE())), 3) 
	+ RIGHT(CONVERT(varchar(4), YEAR(GETDATE())), 2)
    
	
	RETURN @JulianDatecode
END
