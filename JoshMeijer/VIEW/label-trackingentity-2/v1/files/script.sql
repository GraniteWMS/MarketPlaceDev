CREATE VIEW [dbo].[Label_TrackingEntity] AS
WITH ProductionSig AS (
SELECT DISTINCT
([PCS_EventsData].[Mechanical Testing] * 1) +
	([PCS_EventsData].[Chemical Analysis] * 2) +
	([PCS_EventsData].[Radiographic Exam] * 4) +
	([PCS_EventsData].[Impact Testing] * 8) +
	([PCS_EventsData].[Magnetic Testing] * 16) +
	([PCS_EventsData].[Liquid Penetration Testing] * 32) +
	([PCS_EventsData].[Quality Control Plan Required] * 64) +
	([PCS_EventsData].[Customer Inspection Hold Points] * 128) +
	([PCS_EventsData].[HeatTreatment] * 256) AS ProductionSignature
	, cJobCode
	,[PCS_EventsData].iJCTXLineID
FROM [PCS].dbo.PCS_EventsData
	INNER JOIN [PCS].dbo._btblJCMaster ON [PCS].dbo.PCS_EventsData.iJCMasterId = [PCS].dbo._btblJCMaster.IdJCMaster
)
, LabelData AS (
SELECT DISTINCT 
	  dbo.TrackingEntity.Barcode
	, dbo.MasterItem.Code
	, dbo.MasterItem.[Description]
	, dbo.Document.Number Batch
	, dbo.MasterItem.Category
	, dbo.MasterItem.[Type]
	, dbo.MasterItem.UOM
	, idJCTxLines
	, dbo.TrackingEntity.ID
	, dbo.TrackingEntity.Qty
	, _btblJCTxLines.[ucJCTxSTGrossWt] GrossWeight
    , ISNULL(PCS_PatternWHS.[PatternCode],'N/A') [PatternCode]
    , PCS_PatternWHS.[PatternDescription] Patterndescription
    , _btblJCTxLines.[ulJCTxSTCastingMat] [CastingMaterial]
	, _btblJCTxLines.[ucJCTxSTCastingTemperature] CastingTemperature
	, _btblJCTxLines.uiJCTxSTLosePieces NumberOfLoosePieces
    
	    , PCS_PatternWHS.NumberofPatterns [NumberofPatterns]
    
	, ISNULL(CONVERT(VARCHAR, PCS_PatternWHS.NumberofCoreBoxes), 0)  NumberofCores
	, Document.TradingPartnerCode
	, Document.TradingPartnerDescription
	, _btblJCMaster.ulJCType JobType
	
	
    , PCS_PatternWHS.[DrawingNumber]
    
	, CASE WHEN ISNULL(PCS_PatternWHS.[DrawingRevisionNumber],'') = '' THEN '0' ELSE PCS_PatternWHS.[DrawingRevisionNumber] END AS Rev
    
	, CASE WHEN ISNULL(PCS_PatternWHS.DrawingVariantNumber,'') = '' THEN '0' ELSE PCS_PatternWHS.DrawingVariantNumber END AS Variant
    , PCS_PatternWHS.[PatternWHS]
    , PCS_PatternWHS.[Notes]
    , PCS_PatternWHS.[ShelfNumber]
	
	
    
    
	
	, MasterItem.ERPIdentification
	
	, StkItem.ucIICustRef CustRef
	,_btblJCMaster.cExtOrderNo ExtOrderNo
FROM dbo.MasterItem
	INNER JOIN dbo.TrackingEntity			ON dbo.MasterItem.ID = dbo.TrackingEntity.MasterItem_id
	LEFT JOIN Document						ON TrackingEntity.Batch = Document.Number
	INNER JOIN [PCS].dbo._btblJCMaster	ON Document.Number = [PCS].dbo._btblJCMaster.cJobCode COLLATE Latin1_General_CI_AS
	INNER JOIN [PCS].dbo._btblJCTxLines ON [PCS].dbo._btblJCMaster.IdJCMaster		= [PCS].dbo._btblJCTxLines.iJCMasterID
	INNER JOIN  [PCS].dbo.PCS_PatternWHS ON [PCS].dbo.PCS_PatternWHS.JobTxLine		= [PCS].dbo._btblJCTxLines.idJCTxLines
	LEFT JOIN  [PCS].dbo.PCSStockPatternLink ON [PCS].dbo.PCSStockPatternLink.PatternID = [PCS].dbo.PCS_PatternWHS.idColumn
	INNER JOIN [PCS].dbo.StkItem ON [PCS].dbo._btblJCTxLines.iStockID = [PCS].dbo.StkItem.StockLink
		AND [PCS].dbo.StkItem.Code = MasterItem.Code COLLATE Latin1_General_CI_AS
	
																 
)
SELECT DISTINCT LabelData.*
, REPLACE(REPLACE(MAP.[Description],' ',''), ',',' ') Productiondescription
FROM  ProductionSig
	INNER JOIN LabelData ON ProductionSig.cJobCode = LabelData.Batch COLLATE Latin1_General_CI_AS AND ProductionSig.iJCTXLineID = LabelData.idJCTxLines
	INNER JOIN Custom_ProductionSignatureMap MAP ON ISNULL(ProductionSig.ProductionSignature, 0) = ISNULL(MAP.ProductionSignature, 0)
