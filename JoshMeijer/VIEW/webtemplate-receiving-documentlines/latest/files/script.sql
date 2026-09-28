CREATE VIEW [dbo].[WebTemplate_Receiving_DocumentLines]
AS
	SELECT D.Number
		  ,FORMAT(D.CreateDate,'yyyy/MM/dd') Created 
		  ,D.TradingPartnerCode [Partner]
		  ,CASE WHEN D.TradingPartnerDescription LIKE 'IMPORT-%' 
				THEN REPLACE(D.TradingPartnerDescription,'IMPORT-','') 
				ELSE D.TradingPartnerDescription 
				END PartnerName
		  ,ISNULL(FORMAT(D.ExpectedDate,'yyyy/MM/dd'),'') Expected
		  ,D.ID D_ID   
		  ,DD.ID DD_ID, DD.Item_id, MI.Code Code, MI.Description, MIAV.Code Barcode, MIAV.UOM, ISNULL(MIAV.Conversion, 1) Conversion 
		  ,MI.Type LabelType, [Type].[Description] LabelTypeDescription  
	FROM [Document] D 
	INNER JOIN DocumentDetail DD ON DD.Document_id = D.ID 
	INNER JOIN [MasterItem] MI ON MI.ID = DD.Item_id 
	LEFT JOIN [Type] ON [Type].Name = MI.[Type] AND [Type].AppliesTo = 'MASTERITEM'
	LEFT OUTER JOIN MasterItemAlias_View MIAV ON MIAV.MasterItem_id = MI.ID 
	WHERE D.[Type] = 'RECEIVING' 
	AND D.[Status] NOT IN('CANCELLED', 'COMPLETE') 
	AND CASE WHEN DD.Completed = 1 OR DD.Cancelled = 1 
			 THEN ISNULL(DD.ActionQty,0) 
			 ELSE ISNULL(DD.Qty,0) END > ISNULL(DD.ActionQty,0) 
	GROUP BY D.Number, D.ID, FORMAT(CreateDate,'yyyy/MM/dd'), D.TradingPartnerCode, D.TradingPartnerDescription, ISNULL(FORMAT(D.ExpectedDate,'yyyy/MM/dd'),''),  
		     DD.ID, DD.Item_id, MI.Code, MI.Description, MI.Type, MIAV.Code, MIAV.UOM, ISNULL(MIAV.Conversion, 1), 
		     DD.[Type], [Type].[Description] 
