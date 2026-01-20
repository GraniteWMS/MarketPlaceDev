
CREATE VIEW [dbo].[CustomView]
AS
SELECT * FROM 
(SELECT DISTINCT 
                         dbo.[Transaction].ID, dbo.[Transaction].Date, dbo.Users.Name AS [User], dbo.[Transaction].IntegrationStatus, dbo.[Transaction].IntegrationReady, dbo.MasterItem.Code, ISNULL(dbo.[Transaction].UOM, dbo.MasterItem.UOM) 
                         AS UOM, dbo.[Transaction].UOMConversion, dbo.[Transaction].FromQty, dbo.[Transaction].ToQty, dbo.[Transaction].ActionQty, dbo.Location.ERPLocation AS FromLocationERPLocation, 
                         Location_1.ERPLocation AS ToLocationERPLocation, dbo.[Document].Number AS [Document], dbo.DocumentDetail.LineNumber, MasterItem_1.Code AS FromCode, MasterItem_2.Code AS ToCode, dbo.TrackingEntity.Batch, 
                         dbo.[Transaction].Comment, dbo.[Transaction].Type, dbo.[Transaction].Process, dbo.TrackingEntity.SerialNumber, dbo.[Document].Type AS DocumentType, dbo.[Transaction].IntegrationReference, 
                         dbo.[Document].Description AS DocumentDescription, dbo.TrackingEntity.ExpiryDate, [log].Message, dbo.DocumentDetail.Cancelled AS DocumentLineCancelled, Location_1.Site AS ToSite, dbo.Location.Site AS FromSite, 
                         Process.Name,
						 CASE 
						 WHEN dbo.[Transaction].Process ='PICKING' AND dbo.Process.IntegrationIsActive = 0  THEN 
						    (SELECT IntegrationIsActive FROM dbo.Process WHERE [Name] = 'PICKINGPOST')
						 WHEN dbo.[Transaction].Process ='RECEIVING' AND dbo.Process.IntegrationIsActive = 0  THEN 
						    (SELECT IntegrationIsActive FROM dbo.Process WHERE [Name] = 'RECEIVINGPOST')
						 ELSE dbo.Process.IntegrationIsActive END
						 as IntegrationIsActive, 

						 dbo.[Document].TradingPartnerCode AS DocumentTradingPartnerCode, dbo.[Transaction].DocumentReference AS TransactionDocumentReference, dbo.[Transaction].ReversalTransaction_id
FROM            dbo.[Transaction] INNER JOIN
                         dbo.TrackingEntity ON dbo.[Transaction].TrackingEntity_id = dbo.TrackingEntity.ID INNER JOIN
                         dbo.MasterItem ON dbo.TrackingEntity.MasterItem_id = dbo.MasterItem.ID INNER JOIN
                         dbo.Users ON dbo.[Transaction].User_id = dbo.Users.ID LEFT OUTER JOIN
                         dbo.Process ON dbo.[Transaction].Process = dbo.Process.Name LEFT OUTER JOIN
                         dbo.Location AS Location_1 ON dbo.[Transaction].ToLocation_id = Location_1.ID LEFT OUTER JOIN
                         dbo.Location ON dbo.[Transaction].FromLocation_id = dbo.Location.ID LEFT OUTER JOIN
                         dbo.[Document] ON dbo.[Transaction].Document_id = dbo.[Document].ID LEFT OUTER JOIN
                         dbo.MasterItem AS MasterItem_1 ON dbo.[Transaction].FromMasterItem_id = MasterItem_1.ID LEFT OUTER JOIN
                         dbo.MasterItem AS MasterItem_2 ON dbo.[Transaction].ToMasterItem_id = MasterItem_2.ID LEFT OUTER JOIN
                         dbo.DocumentDetail ON dbo.[Transaction].DocumentLine_id = dbo.DocumentDetail.ID OUTER APPLY
						 (
							 SELECT TOP(1) [Message]
							 FROM dbo.IntegrationLog
							 WHERE GraniteTransaction_id = [Transaction].ID
							 ORDER BY [Date] DESC
						 ) [log]
WHERE       dbo.[Transaction].Type NOT IN ('SPLIT','QCHOLD', 'QCRELEASE', 'STOCKTAKE', 'STOCKTAKEHOLD', 'STOCKTAKERELEASE')  AND 
            IntegrationStatus = 0 AND ISNULL(ReversalTransaction_id, 0) = 0
) AS table_1
WHERE table_1.IntegrationIsActive = 1
