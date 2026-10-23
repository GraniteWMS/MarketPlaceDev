CREATE VIEW [dbo].[MasterItemAlias_View]
	AS 
	
	
	
	
	
	
	
	
	
	
	
	
	
	SELECT DISTINCT 0 as ID , AliasItemNo as Code, 'EA' as UOM,1 as Conversion, 1 as isActive,DateCreated as AuditDate, '' as AuditUser, 
	(SELECT ID FROM MasterItem WHERE RTRIM([ItemCode]) COLLATE Latin1_General_CI_AS  = MasterItem.Code) AS MasterItem_id,
	RTRIM([ItemCode]) AS ERPIdentification,1 as Version
	FROM [MAS_STI].dbo.[IM_AliasItem]
	
