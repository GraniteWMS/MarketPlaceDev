
CREATE PROCEDURE [dbo].[Custom_Integration_EVOAPP] AS 
BEGIN
	DECLARE
		  @Document			VARCHAR(50)
		, @Barcode			VARCHAR(50)
		, @RECORDCOUNT		INT
		, @JobID			BIGINT
		, @CurrentAction	VARCHAR(50)
		, @MasterItem		VARCHAR(50)
		, @Comment			VARCHAR(50)
	DECLARE @WIP_TABLE		TABLE (
		  ID				BIGINT IDENTITY
		, Barcode			VARCHAR(50)
		, TE_Location		VARCHAR(50)
		, Document			VARCHAR(50)
		, MasterItem		VARCHAR(50)
		, Comment			VARCHAR(50)
		)
	DECLARE @UPDATE_TABLE		TABLE (
		ID				BIGINT IDENTITY
	, Barcode			VARCHAR(50)
	, TE_Location		VARCHAR(50)
	, Document			VARCHAR(50)
	, MasterItem		VARCHAR(50)
	, Comment			VARCHAR(50)
	)
	
	INSERT INTO @WIP_TABLE
	SELECT DISTINCT TrackingEntity.Barcode, [Location].Barcode, Document.Number, MasterItem.Code, [Transaction].Comment
	FROM [Transaction]
		INNER JOIN TrackingEntity	ON [Transaction].TrackingEntity_id				= TrackingEntity.ID
		INNER JOIN MasterItem		ON TrackingEntity.MasterItem_id					= MasterItem.ID
		INNER JOIN [Location]		ON TrackingEntity.Location_id					= [Location].ID
		INNER JOIN Document			ON [TrackingEntity].Batch						= Document.Number
		LEFT JOIN [PCS].dbo.PCS_JobStock JOBSTOCK ON TrackingEntity.Barcode	= JOBSTOCK.TrackingEntityBarcode COLLATE Latin1_General_CI_AS
	WHERE [Transaction].Process = 'MANUFACTURE'
	AND [Transaction].[Type] = 'MANUFACTURE'
	AND ISNULL(JOBSTOCK.TrackingEntityBarcode, '') = ''
	SELECT @RECORDCOUNT = MAX(ID) FROM @WIP_TABLE
	WHILE @RECORDCOUNT > 0
	BEGIN
		
		SELECT
			  @Document			= Document
			, @CurrentAction	= TE_Location
			, @Barcode			= Barcode
			, @MasterItem		= MasterItem
			, @Comment			= Comment
		FROM @WIP_TABLE WHERE ID = @RECORDCOUNT
		
		
		
		
		
		
		
		
		
		
		SELECT TOP 1 @JobID = idColumn 
			
		FROM [PCS].dbo.PCS_JobStock
			INNER JOIN [PCS].dbo._btblJCMaster ON [PCS].dbo.PCS_JobStock.Jobmaster	= [PCS].dbo._btblJCMaster.IdJCMaster
		WHERE [PCS].dbo._btblJCMaster.cJobCode	= @Document
		  AND [PCS].dbo.PCS_JobStock.StockCode	= @MasterItem
		AND ISNULL([PCS].dbo.PCS_JobStock.TrackingEntityBarcode, '') = ''
		IF ISNULL(@JobID, 0) <> 0
		BEGIN
			UPDATE [PCS].dbo.PCS_JobStock
				SET
					  CurrentAction			= @CurrentAction	
					, TrackingEntitybarcode = @Barcode			
					
			WHERE [PCS].dbo.PCS_JobStock.idColumn = @JobID
			
			UPDATE Document 
				SET [Status] = @CurrentAction
			WHERE Number = @Document
		
		END
		
		
		
		
		
		
		
		SET @JobID = NULL
		SET @RECORDCOUNT -= 1
	END
END
