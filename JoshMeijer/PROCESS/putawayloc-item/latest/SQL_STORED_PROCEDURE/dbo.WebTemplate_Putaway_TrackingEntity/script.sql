CREATE   PROCEDURE [dbo].[WebTemplate_Putaway_TrackingEntity]
    @TrackingEntityBarcode varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    WITH SelectedItem  AS
    (
        SELECT TOP 1
            TE.MasterItem_id
        FROM dbo.TrackingEntity TE
        WHERE TE.Barcode = @TrackingEntityBarcode
    ) 
    SELECT       
		L.[Category] as Zone,
		L.Barcode,
        CONVERT(int,SUM(ISNULL(TE.Qty, 0))) AS Qty
    FROM SelectedItem SI
    INNER JOIN dbo.TrackingEntity TE
        ON TE.MasterItem_id = SI.MasterItem_id
    INNER JOIN dbo.[Location] L
        ON TE.Location_id = L.ID
    WHERE L.[Type] = 'STORAGE'
      AND ISNULL(L.NonStock, 0) = 0
    GROUP BY
        L.Barcode,
        L.[Category]
    ORDER BY
        SUM(ISNULL(TE.Qty, 0)) DESC,
        L.Barcode;
END
