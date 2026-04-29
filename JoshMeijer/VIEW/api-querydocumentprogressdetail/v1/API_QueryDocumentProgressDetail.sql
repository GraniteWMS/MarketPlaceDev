CREATE VIEW [dbo].[API_QueryDocumentProgressDetail]
AS
SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.DocumentDetail.ID AS OrderDetailId, CAST(dbo.DocumentDetail.LineNumber AS bigint) AS LineNumber, dbo.MasterItem.Code, 
                         dbo.MasterItem.Description, dbo.DocumentDetail.UOMQty Qty, dbo.DocumentDetail.UOMQty - (ISNULL(dbo.DocumentDetail.ActionQty, 0) /dbo.DocumentDetail.UOMConversion) AS Outstanding, ISNULL(Tracking.OnHand, 0) / dbo.DocumentDetail.UOMConversion AS QtyOnHand, ISNULL(PickSlip.PickedQty, 
                         0) AS PickedQty, ISNULL(PickSlip.PickslipQty, 0) AS PickSlipQty, dbo.[Document].Status, dbo.[Document].Type, dbo.[Document].Site, dbo.DocumentDetail.ActionQty /dbo.DocumentDetail.UOMConversion ActionQty, dbo.DocumentDetail.Comment, 
                         dbo.DocumentDetail.Instruction, dbo.[Document].ActionDate, dbo.DocumentDetail.UOM, dbo.DocumentDetail.UOMQty, dbo.DocumentDetail.UOMConversion, dbo.DocumentDetail.PackedQty / dbo.DocumentDetail.UOMConversion PackedQty, 
                         dbo.DocumentDetail.FromLocation, dbo.DocumentDetail.Cancelled, dbo.DocumentDetail.Type AS LineType
FROM            dbo.[Document] INNER JOIN
                         dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id INNER JOIN
                         dbo.MasterItem ON dbo.DocumentDetail.Item_id = dbo.MasterItem.ID LEFT OUTER JOIN
                             (SELECT DISTINCT LinkedDetail_id, SUM(UOMQty) AS PickslipQty, SUM(ActionQty) / UOMConversion AS PickedQty
                               FROM            dbo.DocumentDetail AS DocumentDetail_1
                               GROUP BY LinkedDetail_id, UOMConversion) AS PickSlip ON dbo.DocumentDetail.ID = PickSlip.LinkedDetail_id LEFT OUTER JOIN
                             (SELECT DISTINCT dbo.TrackingEntity.MasterItem_id, ISNULL(SUM(dbo.TrackingEntity.Qty), 0) AS OnHand
                               FROM            dbo.TrackingEntity LEFT OUTER JOIN
                                                         dbo.MasterItem AS MasterItem_1 ON dbo.TrackingEntity.MasterItem_id = MasterItem_1.ID INNER JOIN
                                                         dbo.Location ON dbo.TrackingEntity.Location_id = dbo.Location.ID
                               WHERE        (dbo.TrackingEntity.InStock = 1) AND (dbo.Location.NonStock = 0)
                               GROUP BY dbo.TrackingEntity.MasterItem_id) AS Tracking ON dbo.DocumentDetail.Item_id = Tracking.MasterItem_id
