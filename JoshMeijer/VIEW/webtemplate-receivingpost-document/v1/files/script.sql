CREATE VIEW WebTemplate_ReceivingPost_Document
AS
SELECT DISTINCT Document AS DocumentNumber FROM Integration_Transactions WHERE [Type] = 'RECEIVE'
