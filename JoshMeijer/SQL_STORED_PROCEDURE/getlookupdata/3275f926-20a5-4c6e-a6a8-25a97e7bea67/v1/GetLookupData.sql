CREATE PROCEDURE [dbo].[GetLookupData]
	@columnNames nvarchar(max),
    @value NVARCHAR(100)
AS
BEGIN
	SELECT ROW_NUMBER() OVER(ORDER BY MasterItem.ID) as ID,
		MasterItem.ID AS MasterItem_ID
		,MasterItem.Code AS MasterItem_Code
		,MasterItem.FormattedCode AS MasterItem_FormattedCode
		,MasterItem.[Description] AS MasterItem_Description
		,MasterItem.UOM AS MasterItem_UOM
		,MasterItem.isActive AS MasterItem_isActive
		,MasterItem.SinglePickface AS MasterItem_SinglePickface
		,MasterItem.SinglePutaway AS MasterItem_SinglePutaway
		,MasterItem.MaximumReorderQty AS MasterItem_MaximumReorderQty
		,MasterItem.MinimumReorderQty AS MasterItem_MinimumReorderQty
		,MasterItem.MinimumPickfaceQuantity AS MasterItem_MinimumPickfaceQuantity
		,MasterItem.OptimalPickfaceQuantity AS MasterItem_OptimalPickfaceQuantity
		,MasterItem.DirectOnHold AS MasterItem_DirectOnHold
		,MasterItem.LeadTime AS MasterItem_LeadTime
		,MasterItem.ShelfLife AS MasterItem_ShelfLife
		,MasterItem.UnitValue AS MasterItem_UnitValue
		,MasterItem.UnitWeight AS MasterItem_UnitWeight
		,MasterItem.PickingSequence AS MasterItem_PickingSequence
		,MasterItem.EnforceSerialNumber AS MasterItem_EnforceSerialNumber
		,MasterItem.EnforceBatchNumber AS MasterItem_EnforceBatchNumber
		,MasterItem.EnforceExpiryDate AS MasterItem_EnforceExpiryDate
		,MasterItem.EnforceTypeMatchInLocations AS MasterItem_EnforceTypeMatchInLocations
		,MasterItem.EnforceCategoryMatchInLocations AS MasterItem_EnforceCategoryMatchInLocations
		,MasterItem.OverReceivingAllowance AS MasterItem_OverReceivingAllowance
		,MasterItem.LabelName AS MasterItem_LabelName
		,MasterItem.AuditDate AS MasterItem_AuditDate
		,MasterItem.AuditUser AS MasterItem_AuditUser
		,MasterItem.PickfaceLocation_id AS MasterItem_PickfaceLocation_id
		,MasterItem.PutawayLocation_id AS MasterItem_PutawayLocation_id
		,MasterItem.Category AS MasterItem_Category
		,MasterItem.Type AS MasterItem_Type
		,MasterItem.Velocity AS MasterItem_Velocity
		,MasterItem.LastStockTakeDate AS MasterItem_LastStockTakeDate
		,MasterItem.ERPIdentification AS MasterItem_ERPIdentification
		,MasterItem.Length AS MasterItem_Length
		,MasterItem.Width AS MasterItem_Width
		,MasterItem.Height AS MasterItem_Height
		,MasterItem.PackageType AS MasterItem_PackageType
		,TrackingEntity.ID AS TrackingEntity_ID
		,TrackingEntity.Barcode AS TrackingEntity_Barcode
		,TrackingEntity.Qty AS TrackingEntity_Qty
		,TrackingEntity.SerialNumber AS TrackingEntity_SerialNumber
		,TrackingEntity.CreatedDate AS TrackingEntity_CreatedDate
		,TrackingEntity.Value AS TrackingEntity_Value
		,TrackingEntity.Batch AS TrackingEntity_Batch
		,TrackingEntity.ExpiryDate AS TrackingEntity_ExpiryDate
		,TrackingEntity.OnHold AS TrackingEntity_OnHold
		,TrackingEntity.StockTake AS TrackingEntity_StockTake
		,TrackingEntity.InStock AS TrackingEntity_InStock
		,TrackingEntity.MasterItem_id AS TrackingEntity_MasterItem_id
		,TrackingEntity.Location_id AS TrackingEntity_Location_id
		,TrackingEntity.BelongsToEntity_id AS TrackingEntity_BelongsToEntity_id
		,TrackingEntity.ManufactureDate AS TrackingEntity_ManufactureDate
		,[Location].ID AS Location_ID
		,[Location].Barcode AS Location_Barcode
		,[Location].Name AS Location_Name
		,[Location].Site AS Location_Site
		,[Location].ERPLocation AS Location_ERPLocation
		,[Location].isActive AS Location_isActive
		,[Location].NonStock AS Location_NonStock
		,[Location].AuditDate AS Location_AuditDate
		,[Location].AuditUser AS Location_AuditUser
		,[Location].Status AS Location_Status
		,[Location].Type AS Location_Type
		,[Location].Category AS Location_Category
		,[Location].ERPIdentification AS Location_ERPIdentification
		,[Location].Length AS Location_Length
		,[Location].Width AS Location_Width
		,[Location].Height AS Location_Height
		,[Location].MaximumWeight AS Location_MaximumWeight
		,MasterItemAlias_View.ID AS MasterItemAlias_ID
		,MasterItemAlias_View.Code AS MasterItemAlias_Code
		,MasterItemAlias_View.UOM AS MasterItemAlias_UOM
		,MasterItemAlias_View.Conversion AS MasterItemAlias_Conversion
		,MasterItemAlias_View.IsActive AS MasterItemAlias_isActive
		,MasterItemAlias_View.AuditDate AS MasterItemAlias_AuditDate
		,MasterItemAlias_View.AuditUser AS MasterItemAlias_AuditUser
		,MasterItemAlias_View.MasterItem_id AS MasterItemAlias_MasterItem_id
		,MasterItemAlias_View.ERPIdentification AS MasterItemAlias_ERPIdentification
	INTO #LookupDataTempTable
	FROM MasterItem LEFT JOIN 
	TrackingEntity ON MasterItem.ID = TrackingEntity.MasterItem_ID LEFT JOIN 
	[Location] ON TrackingEntity.Location_ID = [Location].ID LEFT JOIN
	MasterItemAlias_View ON MasterItem.ID = MasterItemAlias_View.MasterItem_id
	WHERE MasterItem.Code = @value AND TrackingEntity.Qty > 0
	OR MasterItem.FormattedCode = @value AND TrackingEntity.Qty > 0
	OR MasterItemAlias_View.Code = @value AND TrackingEntity.Qty > 0
	OR [Location].Barcode = @value AND TrackingEntity.Qty > 0
	OR [Location].[Name] = @value AND TrackingEntity.Qty > 0
	OR TrackingEntity.Barcode = @value
	OR TrackingEntity.Batch = @value
	OR TrackingEntity.SerialNumber = @value

	IF EXISTS(SELECT TrackingEntity_Barcode FROM #LookupDataTempTable WHERE MasterItemAlias_Code <> @value)
	BEGIN
		DELETE t1
		FROM #LookupDataTempTable t1 JOIN 
		#LookupDataTempTable t2 ON t1.TrackingEntity_Barcode = t2.TrackingEntity_Barcode AND t1.id > t2.id;
	END

	DECLARE @sql nvarchar(max) = 'SELECT ' + @columnNames + ' FROM #LookupDataTempTable'
	EXEC (@sql)
    
END
