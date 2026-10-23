CREATE PROCEDURE [dbo].[Webtemplate_AssignPickerDetail_MasterItem] 
	@Document NVARCHAR(100) 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT [Line] 
		  ,MI.Code 
		  ,MI.[Description] 
		  ,SUM(CAST(DocumentDetail.Qty - DocumentDetail.ActionQty as decimal(19,0))) Qty
		  ,ISNULL(DocumentDetail.AssignedTo,'') LinePicker 
	FROM Document D with (nolock) 
	OUTER APPLY (SELECT DD.LineNumber [Line]
					   ,DD.Item_id
					   ,CASE WHEN D.[Status] IN ('COMPLETE','CANCELLED')  
							 OR DD.Completed = 1 
							 OR DD.Cancelled = 1 
							 THEN DD.ActionQty 
							 ELSE DD.Qty END Qty 
					   ,DD.ActionQty 
					   ,[Order].[Status] OrderStatus 
					   ,[Order].Number OrderNumber 
					   ,ISNULL([dbo].[FN_GetOptionalField] ('AssignedTo','DOCUMENTDETAIL',DD.ID),'') AssignedTo
				 FROM DocumentDetail DD with (nolock) 
				 OUTER APPLY (SELECT SO.Number, SO.[Status] 
							  FROM DocumentDetail SOD with (nolock)
							  INNER JOIN Document SO with (nolock) ON SO.ID = SOD.Document_id 
							  WHERE SOD.ID = DD.LinkedDetail_id 
							  AND SOD.Item_id = DD.Item_id 
							 ) [Order]  
				 WHERE DD.Document_id = D.ID 
				 AND CASE WHEN D.[Status] IN ('COMPLETE', 'CANCELED', 'CANCELLED')  
							OR DD.Completed = 1 
							OR DD.Cancelled = 1 
							THEN DD.ActionQty 
							ELSE DD.Qty END > ISNULL(DD.ActionQty,0) 
				 AND [Order].[Status] NOT IN ('COMPLETE', 'CANCELED', 'CANCELLED')
				) DocumentDetail 
	INNER JOIN MasterItem MI with (nolock) ON MI.ID = DocumentDetail.Item_id 
	WHERE D.[Type] = 'PICKSLIP' 
	AND D.[Status] NOT IN ('COMPLETE', 'CANCELED', 'CANCELLED') 
	AND D.Number = @Document 
	GROUP BY [Line]
			,MI.Code 
			,MI.[Description]  
			,ISNULL(DocumentDetail.AssignedTo,'')
	ORDER BY MI.Code 
END
