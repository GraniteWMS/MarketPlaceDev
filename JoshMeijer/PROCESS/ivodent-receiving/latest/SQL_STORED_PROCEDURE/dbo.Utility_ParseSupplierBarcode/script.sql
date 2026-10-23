CREATE PROCEDURE [dbo].[Utility_ParseSupplierBarcode]
	@Barcode varchar(max),
	@MasterItem varchar(20) OUTPUT,
	@Batch varchar(30) OUTPUT,
	@TrackingEntityBarcode varchar(50) OUTPUT,
	@ExpiryDate varchar(20) OUTPUT,
	@Serial varchar(30) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Prefix varchar(10) = ''
	DECLARE @Pad int = 0
	SELECT @Serial = ''
	IF CHARINDEX('/', @Barcode) = 0 
	BEGIN
		IF RIGHT(@Barcode, 2) = 'BE' AND LEFT(@Barcode, 2) = '01'
			BEGIN
				SELECT @Barcode = SUBSTRING(@Barcode, 1, LEN(@Barcode)-2)
				SELECT @MasterItem = RIGHT(@Barcode, 6)
				
				
				
				
				
				SELECT @ExpiryDate = null
				SELECT @Batch = SUBSTRING(@Barcode, 27, 10)
				SELECT @Serial = SUBSTRING(@Barcode, 27, 10)
			END
		ELSE
			BEGIN
				IF RIGHT(@Barcode, 2) NOT LIKE '%[^a-zA-Z]%' 
				BEGIN
					SELECT @Barcode = SUBSTRING(@Barcode, 1, LEN(@Barcode)-2)
				END
				DECLARE @reversedBarcode varchar(max)
				SELECT @reversedBarcode = REVERSE(@Barcode)
				SELECT @MasterItem = REVERSE(SUBSTRING(@reversedBarcode, 1,6))
				
				IF SUBSTRING(@reversedBarcode, 10,1) NOT LIKE '[a-zA-Z0-9]' 
					SELECT @Pad = 1
				
				IF RTRIM(SUBSTRING(@reversedBarcode, 7, 4)) = SUBSTRING(@reversedBarcode, 7, 3) 
					SELECT @Pad = 1
				SELECT @Batch = REVERSE(SUBSTRING(@reversedBarcode, 10 + @Pad, 6))
				IF (SUBSTRING(@reversedBarcode, 24 + @Pad, 2)) = '71'
				BEGIN
					SELECT @ExpiryDate = '20' + REVERSE(SUBSTRING(@reversedBarcode, 18 + @Pad, 6))
					IF ISDATE(@ExpiryDate) = 0
					BEGIN
						SELECT @ExpiryDate = null
					END
				END
			END
	END
	ELSE 
	BEGIN
		SELECT @Prefix = 
		CASE 
		WHEN CHARINDEX('+DVIV', @Barcode) > 0 
			THEN '+DVIV'
		WHEN CHARINDEX('+DIVO', @Barcode) > 0 
			THEN '+DIVO'
		ELSE 
			''
		END
		SELECT @MasterItem = SUBSTRING(@Barcode, CHARINDEX(@Prefix, @Barcode) + 5, CHARINDEX('1/', @Barcode) -6)
		IF RIGHT(@MasterItem, 2) = 'AN'
		BEGIN
			SELECT @MasterItem = LEFT(@MasterItem, LEN(@MasterItem) - 2)
		END
		SELECT @MasterItem = REPLACE(@MasterItem, 'WW', '')
		IF CHARINDEX('/$', @Barcode) > 0
		BEGIN
			SELECT @Batch = SUBSTRING(@Barcode, CHARINDEX('/$', @Barcode) + 2, CHARINDEX('/', @Barcode, CHARINDEX('/$', @Barcode) + 1) - (CHARINDEX('/$', @Barcode) + 2))
		END
		
		
		
		
		IF CHARINDEX('/14D', @Barcode) > 0
		BEGIN
			SELECT @ExpiryDate = SUBSTRING(@Barcode, CHARINDEX('/14D', @Barcode) + 4, 8)
			IF ISDATE(@ExpiryDate) = 0
			BEGIN
				SELECT  @ExpiryDate = null
			END
		END
	END
	IF ISNULL(@MasterItem, '') <> '' AND ISNULL(@Batch, '') <> ''
	BEGIN
		SELECT @TrackingEntityBarcode = CONCAT(@Prefix, @MasterItem,'/$', @Batch)
	END
END
