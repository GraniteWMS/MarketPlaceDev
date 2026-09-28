CREATE VIEW [dbo].[Custom_Stock_All_Session]
AS
SELECT
      F.SessionName
    , LTRIM(RTRIM(F.ItemCode))     AS SORTCODE
    , CONVERT(INT, F.TotalQty)     AS QTYCOUNTED
    , 'KG'                         AS UOM
FROM dbo.Custom_vw_Stocktake_Files F
WHERE F.Status = 'COMPLETED';
