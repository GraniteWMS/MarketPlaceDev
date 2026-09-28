CREATE PROCEDURE [dbo].[FIFOPickingRecommendation]
    @Document varchar(30)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocumentID bigint;
    SELECT @DocumentID = ID FROM dbo.Document WHERE Number = @Document;
    IF (ISNULL(@DocumentID, 0) = 0)
        RETURN;
    DECLARE @FifoPickRecommendation TABLE
    (
        DocumentDetailID   bigint,
        LinePriority       int NULL,
        MasterItemID       bigint,
        QtyOrdered         decimal(19,4),
        ActionQty          decimal(19,4),
        Instruction        varchar(250),
        TrackingEntityId   bigint NULL,
        TrackingEntityCode varchar(30) NULL,
        TrackingEntityQty  decimal(19,4) NULL,
        LocationId         bigint NULL,
        LocationName       varchar(100) NULL,
        FromLocation       varchar(50) NULL,
        LocationBarcode    varchar(50) NULL   
    );
    INSERT INTO @FifoPickRecommendation (DocumentDetailID, MasterItemID, QtyOrdered, ActionQty, FromLocation)
    SELECT ID, Item_id, Qty, ActionQty, FromLocation
    FROM dbo.DocumentDetail
    WHERE Document_id = @DocumentID;
    
    UPDATE f
    SET
        TrackingEntityId   = r.ID,
        TrackingEntityCode = r.TrackingEntityBarcode,
        TrackingEntityQty  = r.Qty,
        LocationId         = r.Location_id,
        LocationName       = r.LocationName,
        LocationBarcode    = r.LocationBarcode
    FROM @FifoPickRecommendation f
    JOIN (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY te.MasterItem_id ORDER BY te.CreatedDate) AS RowNum,
            te.ID,
            te.Barcode AS TrackingEntityBarcode,
            te.Qty,
            te.Location_id,
            te.MasterItem_id,
            loc.Name    AS LocationName,
            loc.Category,
            loc.ERPLocation,
            loc.Barcode AS LocationBarcode
        FROM dbo.TrackingEntity te
        INNER JOIN dbo.Location loc
            ON te.Location_id = loc.ID
        WHERE te.Qty <> 0
          AND te.InStock = 1
          AND te.OnHold <> 1
          AND te.MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecommendation)
          AND loc.NonStock = 0
          AND loc.Barcode LIKE '%CHECK%'
    ) AS r
      ON f.MasterItemID = r.MasterItem_id
     AND r.ERPLocation = f.FromLocation;
         
    UPDATE f
    SET
        TrackingEntityId   = r.ID,
        TrackingEntityCode = r.TrackingEntityBarcode,
        TrackingEntityQty  = r.Qty,
        LocationId         = r.Location_id,
        LocationName       = r.LocationName,
        LocationBarcode    = r.LocationBarcode
    FROM @FifoPickRecommendation f
    JOIN (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY te.MasterItem_id ORDER BY te.CreatedDate) AS RowNum,
            te.ID,
            te.Barcode AS TrackingEntityBarcode,
            te.Qty,
            te.Location_id,
            te.MasterItem_id,
            loc.Name    AS LocationName,
            loc.Category,
            loc.ERPLocation,
            loc.Barcode AS LocationBarcode
        FROM dbo.TrackingEntity te
        INNER JOIN dbo.Location loc
            ON te.Location_id = loc.ID
        WHERE te.Qty <> 0
          AND te.InStock = 1
          AND te.OnHold <> 1
          AND te.MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecommendation)
          AND loc.NonStock = 0
          AND loc.Barcode LIKE '%TABLE%'
    ) AS r
      ON f.MasterItemID = r.MasterItem_id
     AND r.ERPLocation = f.FromLocation;
    
    UPDATE f
    SET
        TrackingEntityId   = r.ID,
        TrackingEntityCode = r.TrackingEntityBarcode,
        TrackingEntityQty  = r.Qty,
        LocationId         = r.Location_id,
        LocationName       = r.LocationName,
        LocationBarcode    = r.LocationBarcode
    FROM @FifoPickRecommendation f
    JOIN (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY te.MasterItem_id ORDER BY te.CreatedDate) AS RowNum,
            te.ID,
            te.Barcode AS TrackingEntityBarcode,
            te.Qty,
            te.Location_id,
            te.MasterItem_id,
            loc.Name    AS LocationName,
            loc.Category,
            loc.ERPLocation,
            loc.Barcode AS LocationBarcode
        FROM dbo.TrackingEntity te
        INNER JOIN dbo.Location loc
            ON te.Location_id = loc.ID
        WHERE te.Qty <> 0
          AND te.InStock = 1
          AND te.OnHold <> 1
          AND te.MasterItem_id IN (SELECT MasterItemID FROM @FifoPickRecommendation)
          AND loc.NonStock = 0
    ) AS r
      ON f.MasterItemID = r.MasterItem_id
     AND f.TrackingEntityId IS NULL
     AND r.ERPLocation = f.FromLocation;
    
    UPDATE f
    SET Instruction =
        CASE
            WHEN f.TrackingEntityId IS NULL THEN 'NO STOCK AVAILABLE'
            WHEN f.LocationName = 'Receiving' THEN 'MOVE STOCK FROM RECEIVING'
            ELSE CONCAT('Location: ', f.LocationName)
        END
    FROM @FifoPickRecommendation f;
    
    
    UPDATE f
    SET LinePriority = 0
    FROM @FifoPickRecommendation f
    WHERE f.LocationBarcode LIKE '%TABLE%';
    
    ;WITH RankedNonTable AS
    (
        SELECT
            f.DocumentDetailID,
            rn = ROW_NUMBER() OVER (ORDER BY f.LocationBarcode ASC, f.DocumentDetailID)
        FROM @FifoPickRecommendation f
        WHERE f.LocationBarcode IS NOT NULL
          AND f.LocationBarcode NOT LIKE '%TABLE%'
    )
    UPDATE f
    SET LinePriority = r.rn
    FROM @FifoPickRecommendation f
    JOIN RankedNonTable r
      ON r.DocumentDetailID = f.DocumentDetailID
    WHERE f.LinePriority IS NULL;
    
    ;WITH RankedNulls AS
    (
        SELECT
            f.DocumentDetailID,
            rn = ROW_NUMBER() OVER (ORDER BY f.DocumentDetailID)
        FROM @FifoPickRecommendation f
        WHERE f.LocationBarcode IS NULL
    )
    UPDATE f
    SET LinePriority = 100000 + r.rn
    FROM @FifoPickRecommendation f
    JOIN RankedNulls r
      ON r.DocumentDetailID = f.DocumentDetailID
    WHERE f.LinePriority IS NULL;
    
    UPDATE dd
    SET
        dd.Instruction = fifo.Instruction,
        dd.LinePriority = fifo.LinePriority
    FROM dbo.DocumentDetail dd
    JOIN @FifoPickRecommendation fifo
      ON fifo.DocumentDetailID = dd.ID
    WHERE dd.Document_id = @DocumentID
      AND dd.Completed = 0;
END
