CREATE VIEW [dbo].[Integration_Accpac_TransferHeader] as
SELECT	TRANFENSEQ ERPIdentification,
		RTRIM([DOCNUM]) Number, 
        RTRIM(HDRDESC) [Description], 
		CASE 
			WHEN EXPARDATE = 0 THEN NULL	
			ELSE TRY_CONVERT(DateTime,TRY_CONVERT(varchar(10),EXPARDATE)) 
		END ExpectedDate,
		CASE [STATUS]	
			WHEN 1 THEN 'ENTERED'
			ELSE 'COMPLETE'
		END [Status], 
		detail.FROMLOC [ERPLocation],
		'TRANSFER' [Type],
		CASE 
			WHEN TRANSDATE = 0 THEN GETDATE()
			ELSE ISNULL(TRY_CONVERT(DateTime,TRY_CONVERT(varchar(10),TRANSDATE)), GETDATE())
		END CreateDate,
		'' [Site],
		1 as [isActive]
FROM [TSTDAT].dbo.[ICTREH] with (NOLOCK) OUTER APPLY
(
	SELECT TOP 1 [ICTRED].FROMLOC
	FROM [TSTDAT].dbo.[ICTRED] with (nolock) 
	WHERE [ICTRED].[TRANFENSEQ] = [ICTREH].[TRANFENSEQ]
) detail
WHERE DOCTYPE = 1
