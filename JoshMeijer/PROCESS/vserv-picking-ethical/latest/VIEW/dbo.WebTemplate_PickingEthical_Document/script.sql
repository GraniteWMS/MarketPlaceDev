CREATE VIEW [dbo].[WebTemplate_PickingEthical_Document]
AS
WITH OrderTypes AS
(
SELECT DISTINCT D.ID AS DocumentID,
CASE WHEN MI.Category IN ('HILLS FOOD', 'OTHER FOOD') THEN 'FOOD' ELSE 'ETHICAL' END AS [Type]
FROM DocumentDetail DD
INNER JOIN Document D ON DD.Document_id = D.ID
INNER JOIN MasterItem MI ON DD.Item_id = MI.ID
WHERE D.[Type] = 'ORDER'
)
SELECT D.Number AS DocumentNumber, 
CONVERT(VARCHAR, D.CreateDate, 111) AS CreateDate, D.RouteName, 
CONCAT(D.TradingPartnerCode, ' - ', D.TradingPartnerDescription) AS Customer,
ISNULL(RouteSeq.SequenceNumber, 100) AS SeqNumber,
BusyUser.[CurrentUser] AS [User]
FROM [Document] D 
INNER JOIN OrderTypes ON OrderTypes.DocumentID = D.ID
LEFT JOIN Custom_VW_RouteNameSequence RouteSeq ON RouteSeq.RouteName = IIF(ISNULL(D.RouteName, 'None') LIKE '%Courier%', 'None', ISNULL(D.RouteName, 'None'))
OUTER APPLY
(SELECT TOP 1 U.[Name] AS CurrentUser
FROM [Transaction] T INNER JOIN Users U ON T.[User_id] = U.ID
WHERE T.Document_id = D.ID AND T.[Type] = 'PICK' ORDER BY T.ID DESC) BusyUser
WHERE D.[Type] = 'ORDER' AND D.[Status] NOT IN('CANCELLED', 'COMPLETE', 'ONHOLD') 
AND OrderTypes.[Type] = 'ETHICAL'
