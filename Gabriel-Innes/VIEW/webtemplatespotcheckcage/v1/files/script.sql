CREATE VIEW WebtemplateSpotCheckCage
AS
SELECT Name AS Cage
FROM Category
WHERE AppliesTo = 'LOCATION'
AND Name <> 'DeliveryVehicles'
