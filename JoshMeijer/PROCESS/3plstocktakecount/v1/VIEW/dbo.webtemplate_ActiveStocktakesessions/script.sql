CREATE VIEW [dbo].[webtemplate_ActiveStocktakesessions]
AS
	SELECT [Name] as [Session]
	FROM StockTakeSession 
	
	
	WHERE Active = 1
	
