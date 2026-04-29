IF NOT EXISTS (SELECT 1 FROM [dbo].[DataGrid] WHERE [Name] = 'DocumentTrackingLog' AND [Group] = 'DocumentTracking')
BEGIN
	END
    IF NOT EXISTS (SELECT 1 FROM [Location] WHERE Barcode = '1-DELIVERYAPRON')
    BEGIN
    END
