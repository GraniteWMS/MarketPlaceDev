CREATE VIEW Custom_VW_DocumentERPLocations
AS
SELECT DISTINCT
Document_id AS DocumentID,
ISNULL(D.ERPLocation, ISNULL(DD.ToLocation, DD.FromLocation)) AS ERPLocation
FROM DocumentDetail DD
INNER JOIN Document D ON DD.Document_id = D.ID
