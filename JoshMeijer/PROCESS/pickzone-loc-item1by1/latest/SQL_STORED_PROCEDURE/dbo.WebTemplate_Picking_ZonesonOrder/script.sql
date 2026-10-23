CREATE PROCEDURE [dbo].[WebTemplate_Picking_ZonesonOrder]
@Document NVARCHAR(100)  
AS
BEGIN
	SELECT CASE WHEN DocumentDetail.Instruction LIKE 'ZONE %|%' THEN SUBSTRING(DocumentDetail.Instruction,6,CHARINDEX('|',DocumentDetail.Instruction+'|')-6) ELSE 'UNASSIGNED' END Zone,
	COUNT(*) Lines,
	SUM(CASE WHEN ISNULL(DocumentDetail.ActionQty,0)<DocumentDetail.Qty THEN DocumentDetail.Qty-ISNULL(DocumentDetail.ActionQty,0) ELSE 0 END) Qty,
	1 SortOrder
	FROM Document
	INNER JOIN DocumentDetail ON Document.ID=DocumentDetail.Document_id
	WHERE Number=@Document
	AND ISNULL(DocumentDetail.Instruction,'')<>'NO STOCK AVAILABLE'
	AND ISNULL(DocumentDetail.ActionQty,0)<DocumentDetail.Qty
	GROUP BY CASE WHEN DocumentDetail.Instruction LIKE 'ZONE %|%' THEN SUBSTRING(DocumentDetail.Instruction,6,CHARINDEX('|',DocumentDetail.Instruction+'|')-6) ELSE 'UNASSIGNED' END
	ORDER BY SortOrder,Zone
	
	
	
	
	
	
	
	
END
