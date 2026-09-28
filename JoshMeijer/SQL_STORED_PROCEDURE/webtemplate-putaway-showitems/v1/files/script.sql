CREATE PROCEDURE [dbo].[WebTemplate_Putaway_ShowItems]
@FromLocation NVARCHAR(100)  
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH SourceItems AS
    (
        SELECT DISTINCT
            MI.ID          AS MasterItem_id,
            MI.Code,
            MI.Description,
			CONVERT(int,TE.Qty) as Qty
        FROM dbo.TrackingEntity TE
        INNER JOIN dbo.MasterItem MI
            ON TE.MasterItem_id = MI.ID
        INNER JOIN dbo.[Location] L
            ON TE.Location_id = L.ID
        WHERE L.Barcode = @FromLocation
          AND ISNULL(TE.Qty, 0) > 0
          AND ISNULL(TE.InStock, 0) = 1
    )
    SELECT
        SI.Code,
		SI.Qty as [Qty to Store],
		ISNULL(Locs.Locations, '') AS Locations,
		SI.Description
    FROM SourceItems SI
    OUTER APPLY
    (
        SELECT
            STRING_AGG(X.LocationText, ', ')
                WITHIN GROUP (ORDER BY X.TotalQty DESC, X.LocationText) AS Locations
        FROM
        (
            SELECT
                L2.Barcode AS LocationText,
                SUM(ISNULL(TE2.Qty, 0)) AS TotalQty
            FROM dbo.TrackingEntity TE2
            INNER JOIN dbo.[Location] L2
                ON TE2.Location_id = L2.ID
            WHERE TE2.MasterItem_id = SI.MasterItem_id
              AND L2.[Type] = 'STORAGE'
              AND ISNULL(L2.NonStock, 0) = 0
            GROUP BY
                L2.Barcode
        ) X
    ) Locs
    ORDER BY
        SI.Code;
END
