CREATE VIEW [dbo].[WebTemplate_StockTakeCount_Session]
AS
SELECT [Name] AS [Session], CONVERT(VARCHAR, CreateDate, 111) AS CreatedDate FROM StockTakeSession
