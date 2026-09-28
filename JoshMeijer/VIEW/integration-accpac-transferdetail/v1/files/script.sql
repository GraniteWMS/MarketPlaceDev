CREATE VIEW [dbo].[Integration_Accpac_TransferDetail] as
SELECT	[LINENO] LineNumber, 
		RTRIM(FROMLOC) FromLocation, 
		RTRIM(TOLOC) ToLocation, 
		RTRIM(GITLOC) IntransitLocation, 
		QTYREQ Qty, 
		[QUANTITY] ActionQty, 
		RTRIM(ITEMNO) MasterItem_ERPIdentification, 
		RTRIM(COMMENTS) Comment,
		[ICTREH].[TRANFENSEQ] Document_ERPIdentification,
		[LINENO] ERPIdentification
FROM [TSTDAT].dbo.[ICTRED] with (nolock) INNER JOIN 
[TSTDAT].dbo.[ICTREH] with (NOLOCK) ON [ICTRED].[TRANFENSEQ] = [ICTREH].[TRANFENSEQ]
WHERE [ICTREH].DOCTYPE = 1
