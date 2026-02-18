






CREATE VIEW [dbo].[Custom_BomDetails]
AS



SELECT TOP 100 PERCENT 
Code ITEMNO
,Code BOMNO
,Code COMPONENT
,UnitValue QTY
,UOM UNIT
,UnitValue BUILDQTY
,MasterItem.Code MIXCODE
,isActive AS ISWETCODE
FROM MasterItem
