CREATE PROCEDURE [dbo].[UtilityValidationQty]
	 @InputValue varchar(MAX)
	,@RequiredDataType varchar(50)			
	,@RequiredDecimalSeperator varchar(1)	
	,@RequiredValidateTrackingEntity bit	
	,@RequiredValidateLocation bit			
	,@RequiredValidateDocument bit			
	,@RequiredValidateMasterItem bit		
	,@RequiredValidateMasterItemAlias bit	
	,@RequiredValidateMaxQty bit			
	,@ResultValid bit OUTPUT
	,@ResultMessage varchar(max) OUTPUT
	,@ResultValue varchar(50) OUTPUT
AS
	
BEGIN
	SET NOCOUNT ON;
	
	
	
	
	
	
	
	
	
	
	
	
	
	SET @ResultValid = 1
	SET @ResultMessage = ''
	DECLARE @MaximumQty varchar(50) = (SELECT [Value] FROM SystemStaticData WHERE [Group] = 'ProcessValidation' AND [Key] = 'MaximumQty') 
	IF @InputValue = '' 
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = 'Quantity cannot be empty'
	END 
	
	ELSE IF @InputValue = '0'
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = 'Quantity cannot be 0'
	END 
	ELSE IF @RequiredValidateTrackingEntity = 1 
	AND EXISTS (SELECT ID FROM TrackingEntity WHERE Barcode = @InputValue) 
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = CONCAT(@InputValue, ' is a carton not a quantity')
	END
	
	ELSE IF @RequiredValidateLocation = 1 
	AND EXISTS (SELECT ID FROM [Location] WHERE Barcode = @InputValue or Name = @InputValue) 
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = CONCAT(@InputValue, ' is a location not a quantity')
	END
	
	ELSE IF @RequiredValidateDocument = 1 
	AND EXISTS (SELECT ID FROM Document WHERE Number = @InputValue) 
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = CONCAT(@InputValue, ' is a document number not a quantity')
	END
	
	ELSE IF @RequiredValidateMasterItem = 1 
	AND EXISTS (SELECT ID FROM MasterItem WHERE Code = @InputValue or FormattedCode = @InputValue)
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = CONCAT(@InputValue, ' is an item code not a quantity')
	END
	ELSE IF @RequiredValidateMasterItemAlias = 1 
	AND EXISTS (SELECT ID FROM MasterItemAlias WHERE Code = @InputValue)
	BEGIN
		SET @ResultValid = 0
		SET @ResultMessage = CONCAT(@InputValue, ' is an item code not a quantity')
	END
	
	IF @ResultValid = 1 
	BEGIN
		IF @RequiredDataType = 'int'
		BEGIN
			IF CHARINDEX('.',@InputValue) > 0 
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = 'Quantity must be a number only, decimal not allowed'
			END
			ELSE IF CHARINDEX(',',@InputValue) > 0 
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = 'Quantity must be a number only, decimal not allowed'
			END 
			ELSE
			BEGIN
				BEGIN TRY 
					SELECT @ResultValue = CONVERT(INT, @InputValue) 
					IF CONVERT(INT, @ResultValue)  <= 0 
					BEGIN
						SET @ResultValid = 0
						SET @ResultMessage = 'Quantity cannot be zero or negative'
					END
					ELSE
					BEGIN
						SET @ResultValid = 1
						SET @ResultMessage = 'Good'
					END
				END TRY
				BEGIN CATCH 
					SET @ResultValid = 0
					SET @ResultMessage = CONCAT(@InputValue, ' is not a valid number (',@RequiredDataType,')')	
				END CATCH
			END 
		END
	
		ELSE IF @RequiredDataType = 'bigint'
		BEGIN
			IF CHARINDEX('.',@InputValue) > 0
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = 'Quantity must be a number only, decimal not allowed'
			END
			ELSE IF CHARINDEX(',',@InputValue) > 0 
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = 'Quantity must be a number only, decimal not allowed'
			END 
			ELSE
			BEGIN
				BEGIN TRY 
					SET @ResultValue = CONVERT(BIGINT, @InputValue) 
					IF CONVERT(BIGINT, @ResultValue) <= 0 
					BEGIN
						SET @ResultValid = 0
						SET @ResultMessage = 'Quantity cannot be zero or negative'
					END
					ELSE
					BEGIN
						SET @ResultValid = 1
						SET @ResultMessage = 'Good'
					END
				END TRY
				BEGIN CATCH 
					SET @ResultValid = 0
					SET @ResultMessage = CONCAT(@InputValue, ' is not a valid number (',@RequiredDataType,')')	
				END CATCH
			END 
		END
	
		ELSE IF @RequiredDataType like 'decimal%'
		BEGIN 
			IF ISNULL(@RequiredDecimalSeperator,'') = '' 
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = CONCAT('Required Decimal Seperator must be supplied with RequiredDataType "', @RequiredDataType,'"') 
			END
		
			ELSE IF ISNULL(@RequiredDecimalSeperator,'') NOT IN (',','.') 
			BEGIN
				SET @ResultValid = 0
				SET @ResultMessage = CONCAT('Required Decimal Seperator "', @RequiredDecimalSeperator,'" is not valid for RequiredDataType "', @RequiredDataType,'"') 
			END
		
			ELSE 
			BEGIN
				IF @RequiredDecimalSeperator = '.' 
				AND CHARINDEX(',',@InputValue) > 0
				BEGIN
					SET @ResultValue = REPLACE(@InputValue,',',@RequiredDecimalSeperator)
				END
				ELSE IF @RequiredDecimalSeperator = ',' 
				AND CHARINDEX('.',@InputValue) > 0
				BEGIN
					SET @ResultValue = REPLACE(@InputValue,'.',@RequiredDecimalSeperator)
				END
				ELSE
				BEGIN 
					SET @ResultValue = @InputValue 
				END
				
				DECLARE @SQL NVARCHAR(MAX); 
				DECLARE @OutputValue SQL_VARIANT;  
				SET @SQL = 'DECLARE @ConvertedValue ' + @RequiredDataType + ';
							SET @ConvertedValue = CONVERT(' + @RequiredDataType + ', ''' + @ResultValue + ''');
							SET @OutputValue = @ConvertedValue; ';
				BEGIN TRY 
					EXEC sp_executesql @SQL, N'@OutputValue SQL_VARIANT OUTPUT', @OutputValue OUTPUT; 
					SET @ResultValue = CAST(@OutputValue as varchar) 
					SET @ResultValid = 1
					SET @ResultMessage = 'Good'
				END TRY
				BEGIN CATCH 
					SET @ResultValid = 0
					SET @ResultMessage = CONCAT(@InputValue, ' failed to convert to ', @RequiredDataType)	
				END CATCH
			END
		END
		ELSE IF @RequiredDataType = 'varchar'
		BEGIN
			SET @ResultValue = @InputValue 
			SET @ResultValid = 1 
			SET @ResultMessage = 'Good' 
		END
	END
	IF @ResultValid = 1
	BEGIN
		IF @RequiredValidateMaxQty = 1
		AND CAST(@ResultValue as decimal(19,4)) > CAST(@MaximumQty as decimal(19,4))
		BEGIN
			SET @ResultValid = 0
			SET @ResultMessage = Concat('Quantity entered higher than the current maximum: ', @MaximumQty)
		END
	END  
END
