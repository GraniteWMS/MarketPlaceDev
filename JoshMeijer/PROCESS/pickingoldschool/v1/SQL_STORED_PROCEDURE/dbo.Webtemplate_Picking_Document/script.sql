CREATE PROCEDURE [dbo].[Webtemplate_Picking_Document]
	@PickType int
AS
BEGIN
	IF @PickType = 1
	BEGIN
		SELECT
		[Description] AS Document
		,FORMAT(Createdate, 'yyyy/MM/dd') CreateDate
		,TradingPartnerCode AS TPCode
		FROM Document
		WHERE [Type] = 'ORDER'
		AND isActive = 1
		AND [Status] NOT IN ('COMPLETE', 'ONHOLD', 'CANCELLED')
		AND CreateDate >= '2026-02-01' 
		AND (
			ISNULL([Description], '') LIKE 'ODS%'
			OR ISNULL([Description], '') LIKE 'SRU%'
		)
		AND ISNULL(RouteName, '') <> 'Handling Fee'
		ORDER BY
		CreateDate DESC
		,CASE 
			WHEN [Description] LIKE 'ODS%' THEN 1
			WHEN [Description] LIKE 'SRU%' THEN 2
        ELSE 3
		END
		,[Description] DESC
	END
	ELSE IF @PickType = 2
	BEGIN
		;WITH DetailToLocation AS (
			SELECT DISTINCT
			Document_id
			,ToLocation
			FROM DocumentDetail
		)
		SELECT
		Number AS Document
		,FORMAT(Createdate, 'yyyy/MM/dd') CreateDate
		,DetailToLocation.ToLocation AS ToLocation
		FROM Document
		LEFT JOIN DetailToLocation ON Document.ID = DetailToLocation.Document_id
		WHERE [Type] = 'ORDER'
		AND isActive = 1
		AND [Status] NOT IN ('COMPLETE', 'ONHOLD', 'CANCELLED')
		AND CreateDate >= '2026-02-01'
		AND Number LIKE 'TR-%'
		AND ISNULL(DetailToLocation.ToLocation, '') <> 'Granite 2'
		AND ISNULL(RouteName, '') <> 'Handling Fee'
		ORDER BY
		CreateDate DESC
	
	END
	ELSE IF @PickType = 3
	BEGIN
		SELECT
		Number AS Document
		,FORMAT(Createdate, 'yyyy/MM/dd') CreateDate
		,TradingPartnerCode AS TPCode
		FROM Document
		WHERE [Type] = 'ORDER'
		AND isActive = 1
		AND [Status] NOT IN ('COMPLETE', 'ONHOLD', 'CANCELLED')
		AND CreateDate >= '2026-02-01'
		AND Number LIKE 'SO-%'
		AND LEFT(ISNULL([Description], ''), 3) NOT IN ('ODS', 'SRU')
		AND ISNULL(RouteName, '') <> 'Handling Fee'
		ORDER BY
		CreateDate DESC
	END
	ELSE
	BEGIN
		SELECT
		Number AS Document
		,FORMAT(Createdate, 'yyyy/MM/dd') CreateDate
		,TradingPartnerCode AS TPCode
		FROM Document
		WHERE [Type] = 'ORDER'
		AND isActive = 1
		AND [Status] NOT IN ('COMPLETE', 'ONHOLD', 'CANCELLED')
		AND CreateDate >= '2026-02-01'
		AND Number LIKE 'SO-%'
		
		AND ISNULL(RouteName, '') = 'Handling Fee'
		ORDER BY
		CreateDate DESC
	END
END
