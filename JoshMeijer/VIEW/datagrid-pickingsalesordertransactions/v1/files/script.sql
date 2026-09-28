CREATE VIEW dbo.DataGrid_PickingSalesOrderTransactions
AS
SELECT   ID, Date, FromQty, ToQty, ActionQty, DocumentDetailQty, FromDocumentDetailQty, ToDocumentDetailQty, UOM, UOMConversion, DocumentReference, Comment, IntegrationStatus, 
                         IntegrationReady, IntegrationDate, IntegrationReference, FromValue, ToValue, TrackingEntity_id, FromTrackingEntity_id, User_id, FromLocation_id, ToLocation_id, FromMasterItem_id, 
                         ToMasterItem_id, Document_id, DocumentLine_id, OptionalField_id, Type, Process, ActivityCost, ReversalTransaction_id, LinkedTransaction_id, FromContainableEntity_id, 
                         ToContainableEntity_id
FROM         dbo.[Transaction]
WHERE     (Process = 'PICKING SALES ORDER')
