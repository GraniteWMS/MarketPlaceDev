CREATE VIEW [dbo].[Label_Pallet]
AS
WITH RankedTrackingEntities AS
(
    SELECT
        CE.ID AS CarryingEntity_id,
        CE.Barcode,
        CE.SSCC,
        TE.ID AS TrackingEntity_id,
        TE.Batch,
        TE.Qty,
        TE.CreatedDate,
        TE.MasterItem_id,
        ROW_NUMBER() OVER
        (
            PARTITION BY CE.ID
            ORDER BY TE.ID
        ) AS TrackingEntityNumber
    FROM dbo.CarryingEntity CE
    INNER JOIN dbo.TrackingEntity TE
        ON CE.ID = TE.BelongsToEntity_id
)
SELECT
    RTE.Barcode,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN RTE.SSCC
        END
    ) AS SSCC,
    
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN RTE.Batch
        END
    )
    +
    CASE
        WHEN MAX
        (
            CASE
                WHEN RTE.TrackingEntityNumber = 2
                THEN ISNULL(RTE.Batch, '')
            END
        ) <> ''
        THEN
            '/' +
            MAX
            (
                CASE
                    WHEN RTE.TrackingEntityNumber = 2
                    THEN RTE.Batch
                END
            )
        ELSE ''
    END AS Batch,
    
    SUM(ISNULL(RTE.Qty, 0)) AS PalletQty,
    
    MIN(RTE.CreatedDate) AS ProductionDate,
    
    'Plant 2 - Lake Mills, WI' AS ProductionPlant,
    
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN RTE.Batch
        END
    ) AS Batch1,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN SUBSTRING(RTE.Batch, 1, 3)
        END
    ) AS JDay,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN CEILING(RTE.Qty)
        END
    ) AS [Count1],
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN MI.Code
        END
    ) AS Code,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 1
            THEN MI.Description
        END
    ) AS Description,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 2
            THEN RTE.Batch
            ELSE ''
        END
    ) AS Batch2,
    MAX
    (
        CASE
            WHEN RTE.TrackingEntityNumber = 2
            THEN CEILING(RTE.Qty)
            ELSE 0
        END
    ) AS Count2
FROM RankedTrackingEntities RTE
INNER JOIN dbo.MasterItem MI
    ON RTE.MasterItem_id = MI.ID
GROUP BY
    RTE.CarryingEntity_id,
    RTE.Barcode;
