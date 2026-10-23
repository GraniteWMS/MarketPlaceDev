CREATE PROCEDURE [dbo].[Utility_CheckQtyLimit]
	@Qty varchar(50)
	,@valid bit OUTPUT
	,@message varchar(MAX) OUTPUT
AS
BEGIN TRY
    IF TRY_CONVERT(decimal(18,6), @Qty) IS NULL
        RAISERROR('ERROR: Invalid number.', 16, 1)
	IF TRY_CONVERT(decimal(18,6), @Qty) > 9999
		RAISERROR('ERROR: Qty entered exceeds the maximum of 9999.', 16, 1)
    IF TRY_CONVERT(decimal(18,6), @Qty) != FLOOR(TRY_CONVERT(decimal(18,6), @Qty))
        RAISERROR('ERROR: Value may not contain decimals.', 16, 1)
END TRY
BEGIN CATCH
	SELECT @valid = 0
	,@message = ERROR_MESSAGE()
END CATCH
