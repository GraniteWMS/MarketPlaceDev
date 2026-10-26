CREATE VIEW [dbo].[WebTemplate_ConsumePost_Document]
AS
SELECT Document AS DocumentNumber, FromLocationERPLocation AS [Location], MAX([Date]) AS LastActivity FROM Integration_Transactions WHERE [Type] = 'CONSUME' GROUP BY Document, FromLocationERPLocation
