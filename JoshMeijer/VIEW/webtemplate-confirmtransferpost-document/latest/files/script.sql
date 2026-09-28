CREATE VIEW [dbo].[WebTemplate_ConfirmTransferPost_Document]
AS
SELECT Document AS DocumentNumber, MAX([Date]) AS LastActivity FROM Integration_Transactions_TRANSFERCONFIRMPOST GROUP BY Document
