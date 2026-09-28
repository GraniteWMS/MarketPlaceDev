CREATE VIEW [dbo].[Custom_Report_Stock_All]
AS
    SELECT  
          MI.Code AS [Product Code],
          MI.[Description] AS [Product Name],
          NULL AS Bin,
          IIF(MI.UOM = 'Weight (kg', 'Weight (kg)', MI.UOM) AS Unit,
          TE.Batch AS BatchSN,
          CONVERT(VARCHAR, TE.ExpiryDate, 112) AS [ExpiryDate_YYYYMMDD],
          SUM(TE.Qty) AS [Quantity On Hand],
          SUM(TE.Qty) AS [Stocktake Quantity]
    FROM dbo.MasterItem MI
    INNER JOIN dbo.TrackingEntity TE ON MI.ID = TE.MasterItem_id
    INNER JOIN dbo.[Location] L ON TE.Location_id = L.ID
    LEFT JOIN dbo.CarryingEntity CE ON TE.BelongsToEntity_id = CE.ID
    WHERE 
        TE.InStock = 1
        AND TE.Qty > 0
        AND ISNULL(L.ERPLocation, '') = 'Procurement'
    GROUP BY 
          MI.Code,
          MI.[Description],
          IIF(MI.UOM = 'Weight (kg', 'Weight (kg)', MI.UOM),
          TE.Batch,
          CONVERT(VARCHAR, TE.ExpiryDate, 112)
        
