CREATE VIEW [dbo].[WebTemplate_ManufacturePost_Document]
AS
SELECT Document AS DocumentNumber, ToLocationERPLocation AS [Location], MAX([Date]) AS LastActivity FROM Integration_Transactions WHERE [Type] = 'MANUFACTURE' GROUP BY Document, ToLocationERPLocation
