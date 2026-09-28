INSERT INTO [dbo].[Functions]
           ([Name]
           ,[Description]
           ,[Module]
           ,[Script]
           ,[IsActive])
SELECT
'GenerateStockOnHandFile',
'Generate Stock On Hand File',
'TRACKINGENTITY',
'WebDesktopFunction_GenerateStockOnHandFile',
1