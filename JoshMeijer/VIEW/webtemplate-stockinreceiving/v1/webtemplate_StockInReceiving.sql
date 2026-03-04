CREATE VIEW [dbo].[webtemplate_StockInReceiving]
AS
SELECT        TE.Barcode, TE.Qty,MI.Code, MI.[Description],L.Name
FROM         TrackingEntity TE Inner Join 
dbo.[Location] L ON TE.Location_id = L.ID inner join
dbo.[MasterItem] MI on TE.MasterItem_id = MI.ID
WHERE        L.[Type]  = 'RECEIVING' AND TE.Qty  >0 and TE.InStock =1



