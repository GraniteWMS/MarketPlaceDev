
CREATE PROCEDURE [dbo].[PickingSuggestion] 
	@Document varchar(50)
AS
BEGIN
	
	
	
	SET NOCOUNT ON;
	DECLARE @DisplayFormat varchar(max)
	DECLARE @TEOrderBy varchar(max)
	DECLARE @NumberOfSuggestions int
	DECLARE @DecimalPlaces int
	DECLARE @ExcludeLocations varchar(max)
	DECLARE @ExcludeLocationTypes varchar(max)
	DECLARE @ExcludeLocationCategories varchar(max)
	DECLARE @Separator varchar(5)
	DECLARE @LineOrderBy varchar(max)
	DECLARE @ItemCounter int
	DECLARE @NumItems int
	DECLARE @SuggestionCounter int
	DECLARE @TECounter int
	DECLARE @TESQL varchar(max)
	DECLARE @MasterItemID bigint
	DECLARE @ERPLocation varchar(50)
	DECLARE @SuggestionString varchar(max)
	DECLARE @FirstLocation varchar(50)
	DECLARE @DocumentLineItems TABLE (
	RowNum int,
	DocumentID bigint,
	MasterItemID bigint,
	ERPLocation varchar(50),
	Suggestion varchar(max),
	FirstLocation varchar(50)
	)
	DECLARE @TrackingEntities TABLE (
	RowNum int,
	RowNumPerItem int,
	MasterItemID bigint,
	TrackingEntity varchar(20),
	Batch varchar(50),
	ExpiryDate datetime,
	SerialNumber varchar(50),
	Qty decimal(19,4),
	LocationBarcode varchar(50),
	LocationName varchar(50),
	ERPLocation varchar(50)
	)
	DECLARE @PickSequence TABLE (
	LocationBarcode varchar(50),
	PickSequence varchar(50)
	)
	INSERT INTO @PickSequence
	EXEC PickSequence
	SELECT @DisplayFormat = DisplayFormat, 
		   @TEOrderBy = TEOrderBy, 
		   @DecimalPlaces = DecimalPlaces,
		   @NumberOfSuggestions = CASE WHEN CONVERT(int,ISNULL(SuggestionQty,'0')) < 1 THEN 1 ELSE SuggestionQty END,
		   @ExcludeLocations = CASE WHEN ISNULL(ExcludeLocations,'') = '' THEN 'NoExclusions' ELSE ExcludeLocations END,
		   @ExcludeLocationTypes = CASE WHEN ISNULL(@ExcludeLocationTypes,'') = '' THEN 'NoExclusions' ELSE ExcludeLocationTypes END,
		   @ExcludeLocationCategories = CASE WHEN ISNULL(ExcludeLocationCategories,'') = '' THEN 'NoExclusions' ELSE ExcludeLocationCategories END,
		   @Separator = SuggestionSeparator,
		   @LineOrderBy = CASE WHEN ISNULL(LineOrderBy,'') = '' THEN 'Default' ELSE LineOrderBy END
	FROM (SELECT [Value], [Key]
		  FROM SystemStaticData
		  WHERE [Group] = 'PickingSuggestion'
		 ) TSQL
	PIVOT(MIN([Value])
		  FOR [Key] IN (DisplayFormat,
						TEOrderBy,
						DecimalPlaces,
						SuggestionQty,
						ExcludeLocations,
						ExcludeLocationTypes,
						ExcludeLocationCategories,
						SuggestionSeparator,
						LineOrderBy)
		 ) AS Piv		
	INSERT INTO @DocumentLineItems (RowNum, DocumentID, MasterItemID, ERPLocation)
	SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY DD.Item_id), DD.Document_id, DD.Item_id, FromLocation
	FROM Document D
	INNER JOIN DocumentDetail DD ON DD.Document_id = D.ID
								AND DD.Completed = 0
								AND DD.Cancelled = 0
								AND DD.ActionQty < DD.Qty
	WHERE D.Number = @Document
	SET @ItemCounter = 1
	SELECT TOP 1 @NumItems = RowNum
	FROM @DocumentLineItems
	ORDER BY RowNum DESC
	IF ISNULL(@NumItems,0) > 0
	BEGIN
		WHILE @ItemCounter <= @NumItems
		BEGIN
			SELECT @MasterItemID = MasterItemID, @ERPLocation = ERPLocation
			FROM @DocumentLineItems
			WHERE RowNum = @ItemCounter
			SET @TESQL = CONCAT('SELECT TOP (',@NumberOfSuggestions,') ',@ItemCounter,', '
							   ,'ROW_NUMBER() OVER(ORDER BY ',@TEOrderBy,'), '
							   ,'TE.Masteritem_id, TE.Barcode, TE.Batch, TE.ExpiryDate, TE.SerialNumber, TE.Qty, L.Barcode, L.[Name], L.ERPLocation '
							   ,'FROM TrackingEntity TE '
							   ,'INNER JOIN [Location] L ON L.ID = TE.Location_id AND L.NonStock = 0 AND TE.InStock = 1 AND TE.OnHold = 0 AND TE.Qty > 0 '
							   ,'WHERE TE.Masteritem_id = ',@MasterItemID,' '
							   ,'AND ISNULL(L.ERPLocation,'''') = ''',@ERPLocation,''' '
							   ,'AND TE.ExpiryDate IS NOT NULL '
							   ,'AND L.Barcode NOT IN (''',REPLACE(@ExcludeLocations,',',''','''),''') '
							   ,'AND ISNULL(L.Type,'''') NOT IN (''',REPLACE(@ExcludeLocationTypes,',',''','''),''') '
							   ,'AND ISNULL(L.Category,'''') NOT IN (''',REPLACE(@ExcludeLocationCategories,',',''','''),''') '
							   )
			INSERT INTO @TrackingEntities
			EXEC (@TESQL)
			SET @ItemCounter = @ItemCounter + 1
		END
		SET @SuggestionCounter = 1
		WHILE @SuggestionCounter <= @NumItems
		BEGIN
			SET @TECounter = 1
			SET @SuggestionString = ''
			SET @FirstLocation = ''
			WHILE @TECounter <= @NumberOfSuggestions
			BEGIN
				IF EXISTS(SELECT RowNum FROM @TrackingEntities WHERE RowNum = @SuggestionCounter AND RowNumPerItem = @TECounter)
				BEGIN
					SELECT @SuggestionString = CONCAT(@SuggestionString, 
													REPLACE(
															REPLACE(
																	REPLACE(
																			REPLACE(
																					REPLACE(
																							REPLACE(
																									REPLACE(
																											@DisplayFormat
																											,'@LocationName',TE.LocationName)
																									,'@LocationBarcode',TE.LocationBarcode)
																							,'@TrackingEntity',TE.TrackingEntity)
																					,'@Batch',TE.Batch)
																			,'@ExpiryDate',CONVERT(varchar,TE.ExpiryDate,101))
																	,'@SerialNumber',TE.SerialNumber)
															,'@Qty',CASE WHEN @DecimalPlaces = 0 
																		 THEN CONVERT(varchar,CONVERT(decimal(19,0),TE.Qty))
																		 WHEN @DecimalPlaces = 1 
																		 THEN CONVERT(varchar,CONVERT(decimal(19,1),TE.Qty))
																		 WHEN @DecimalPlaces = 2 
																		 THEN CONVERT(varchar,CONVERT(decimal(19,2),TE.Qty))
																		 WHEN @DecimalPlaces = 3 
																		 THEN CONVERT(varchar,CONVERT(decimal(19,3),TE.Qty))
																		 WHEN @DecimalPlaces = 4 
																		 THEN CONVERT(varchar,TE.Qty)
																	END)
														,@Separator),
							@FirstLocation = ISNULL(TE.LocationBarcode,'TEST')  
					FROM @TrackingEntities TE  
					WHERE TE.RowNum = @SuggestionCounter
					  AND TE.RowNumPerItem = @TECounter
				END
				ELSE IF @TECounter = 1
				BEGIN
					SET @SuggestionString = 'No Stock'
				END
				
				SET @TECounter = @TECounter + 1
			END
			UPDATE DLI
			SET Suggestion = CASE WHEN @SuggestionString NOT IN ('No Stock','')
								  THEN LEFT(@SuggestionString,(LEN(@SuggestionString)-LEN(@Separator)))
								  ELSE @SuggestionString
							 END,
				FirstLocation =  @FirstLocation
			FROM @DocumentLineItems DLI
			WHERE RowNum = @SuggestionCounter
			SET @SuggestionCounter = @SuggestionCounter + 1
		END
		UPDATE DD
		SET Instruction = DLI.Suggestion,
			LinePriority = ISNULL(PS.PickSequence,9999)
		FROM DocumentDetail DD
		INNER JOIN @DocumentLineItems DLI ON DD.Item_id = DLI.MasterItemID
										 AND DD.FromLocation = DLI.ERPLocation
										 AND DD.Document_id = DLI.DocumentID
		LEFT JOIN @PickSequence PS ON PS.LocationBarcode = DLI.FirstLocation
	END
	
	
	
	
	
END
