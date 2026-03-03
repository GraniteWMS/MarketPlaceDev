CREATE VIEW [dbo].[Label_ReceiptSummary]
AS
SELECT        TOP (100) PERCENT dbo.[Document].Number AS DocumentNumber, dbo.MasterItem.Code, SUM(dbo.[Transaction].ActionQty) AS PalletQty, dbo.CarryingEntity.Barcode AS Pallet, 
                         dbo.[Transaction].IntegrationReference, ERP.RCPNUMBER, ERP.DOCTOTAL, ERP.VDCODE, ERP.VDNAME
FROM            dbo.MasterItem RIGHT  JOIN
                         dbo.TrackingEntity LEFT  JOIN
                         dbo.Location AS Location_2 ON dbo.TrackingEntity.Location_id = Location_2.ID ON dbo.MasterItem.ID = dbo.TrackingEntity.MasterItem_id RIGHT  JOIN
                         dbo.[Document] RIGHT  JOIN
                         dbo.[Transaction] LEFT  JOIN
                         dbo.CarryingEntity ON dbo.[Transaction].ContainableEntity_id = dbo.CarryingEntity.ID LEFT  JOIN
                         dbo.Location AS Location_1 ON dbo.[Transaction].ToLocation_id = Location_1.ID ON dbo.[Document].ID = dbo.[Transaction].Document_id LEFT  JOIN
                         dbo.Users ON dbo.[Transaction].User_id = dbo.Users.ID LEFT OUTER JOIN
                         dbo.Location ON dbo.[Transaction].FromLocation_id = dbo.Location.ID ON dbo.TrackingEntity.ID = dbo.[Transaction].TrackingEntity_id LEFT  JOIN 
						 dbo.ERP_ReceiptHeader ERP ON [Transaction].IntegrationReference = ERP.RCPNUMBER COLLATE Latin1_General_CI_AS
WHERE        (dbo.[Transaction].Type = 'RECEIVE')
GROUP BY dbo.MasterItem.Code, dbo.[Document].Number, dbo.CarryingEntity.Barcode, dbo.[Transaction].IntegrationReference,ERP.RCPNUMBER, ERP.DOCTOTAL, ERP.VDCODE, ERP.VDNAME
