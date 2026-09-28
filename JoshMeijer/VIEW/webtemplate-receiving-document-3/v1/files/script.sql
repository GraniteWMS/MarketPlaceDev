CREATE VIEW WebTemplate_Receiving_Document
AS
SELECT Number AS DocumentNumber, CreateDate FROM [Document] WHERE [Type] = 'RECEIVING' AND [Status] NOT IN('CANCELLED', 'COMPLETE')
