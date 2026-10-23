CREATE view [dbo].[Integration_Accpac_SalesOrderHeader] AS
SELECT  ORDUNIQ ERPIdentification, 
		RTRIM([ORDNUMBER]) Number, 
		RTRIM(CUSTOMER) TradingPartnerCode, 
		ISNULL(RTRIM(SHPNAME),RTRIM(BILNAME)) TradingPartnerDescription, 
		RTRIM([DESC]) [Description],
		RTRIM([LOCATION]) ERPLocation,
		CASE 
			WHEN EXPDATE = 0 THEN GETDATE() 
			ELSE TRY_CONVERT(DateTime, TRY_CONVERT(varchar(10), EXPDATE)) 
		END [ExpectedDate],
		CASE 
			WHEN [COMPLETE] > 2 THEN 'COMPLETE'  
			WHEN [ONHOLD] = 1 THEN 'ONHOLD' 
			ELSE 'RELEASED' 
		END [Status],		
		CASE 
			WHEN ORDDATE = 0 THEN GETDATE() 
			ELSE ISNULL(TRY_CONVERT(DateTime, TRY_CONVERT(varchar(10), ORDDATE)) , GETDATE())
		END CreateDate,
		'' [Site],
		'ORDER' [Type],
		1 as [isActive]
FROM [DFI-DC-01].[WMSTST].dbo.[OEORDH] with (nolock)
WHERE [Type] = 1 AND TRY_CONVERT(DateTime, TRY_CONVERT(varchar(10), ORDDATE)) >getdate() - 30
