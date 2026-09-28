CREATE VIEW [dbo].[WebTemplate_LoadPrepItems]
AS
SELECT DISTINCT D.Number AS Document, 
				CASE WHEN MI.[Type] = 'RODS'
					 THEN MI.Code 
					 ELSE 'Package'
				END AS ItemCode, 
				CASE WHEN MI.[Type] = 'RODS'
					 THEN MI.[Description]
					 ELSE 'Package / loose items (Non-Rods)'
				END AS ItemDescription
FROM [MasterItem] MI
INNER JOIN DocumentDetail DD ON DD.Item_id = MI.ID
							AND DD.ActionQty > 0
							AND DD.Cancelled = 0
INNER JOIN Document D ON DD.Document_id = D.ID
