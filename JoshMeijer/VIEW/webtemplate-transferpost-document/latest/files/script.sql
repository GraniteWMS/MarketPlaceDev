CREATE VIEW [dbo].[WebTemplate_TransferPost_Document]
AS
SELECT Document AS DocumentNumber, MAX([Date]) AS LastActivity FROM Integration_Transactions_TRANSFERPOST GROUP BY Document
