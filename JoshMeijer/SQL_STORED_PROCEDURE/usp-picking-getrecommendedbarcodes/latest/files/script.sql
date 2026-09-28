CREATE PROCEDURE [dbo].[usp_Picking_GetRecommendedBarcodes]
      @MasterItemID   bigint
    , @RequiredQty    decimal(19,6) = 0
    , @Warehouse      varchar(50) = NULL
    , @ExcludeBarcode varchar(50) = NULL
    , @TopCount       int = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Today date = CONVERT(date, GETDATE());
    
    
    SET @TopCount = 15;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    DECLARE @Eligible TABLE
    (
          Barcode                varchar(50) NOT NULL
        , Qty                    decimal(19,6) NOT NULL
        , Batch                  varchar(50) NULL
        , SerialNumber           varchar(100) NULL
        , CreatedDate            datetime NULL
        , ExpiryDate             datetime NULL
        , LocationName           varchar(100) NULL
        , CanFulfillOrder        int NOT NULL
        , SizeRank               int NOT NULL
        , DifferenceQty          decimal(19,6) NOT NULL
        , WarehouseRank          int NOT NULL
        , ShelfLifeRemaining     decimal(19,6) NOT NULL
        , ShelfLifePreferenceRank int NOT NULL
    );
    ;WITH BaseEligible AS
    (
        SELECT
              TE.Barcode
            , TE.Qty
            , TE.Batch
            , TE.SerialNumber
            , TE.CreatedDate
            , TE.ExpiryDate
            , L.[Name] AS LocationName
            , CASE
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty >= @RequiredQty
                      THEN 1
                  ELSE 0
              END AS CanFulfillOrder
            , CASE
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty BETWEEN
                       (@RequiredQty * 0.90)
                       AND
                       (@RequiredQty * 1.10)
                      THEN 1
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND @RequiredQty <= 25
                   AND TE.Qty <= 25
                   AND TE.Qty >= @RequiredQty
                      THEN 2
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND @RequiredQty <= 25
                   AND TE.Qty <= 25
                   AND TE.Qty < @RequiredQty
                      THEN 3
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty >= @RequiredQty
                   AND TE.Qty <= (@RequiredQty * 1.50)
                      THEN 4
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty < @RequiredQty
                   AND TE.Qty >= (@RequiredQty * 0.50)
                      THEN 5
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty > (@RequiredQty * 1.50)
                   AND TE.Qty <= (@RequiredQty * 5)
                      THEN 6
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty < @RequiredQty
                      THEN 7
                  
                  WHEN ISNULL(@RequiredQty, 0) > 0
                   AND TE.Qty > (@RequiredQty * 5)
                      THEN 8
                  ELSE 9
              END AS SizeRank
            , CASE
                  WHEN ISNULL(@RequiredQty, 0) > 0
                      THEN ABS(TE.Qty - @RequiredQty)
                  ELSE 999999999
              END AS DifferenceQty
            , CASE
                  WHEN UPPER(LTRIM(RTRIM(ISNULL(L.[Type], 'SAVOURY'))))
                       =
                       UPPER(LTRIM(RTRIM(ISNULL(@Warehouse, 'SAVOURY'))))
                      THEN 1
                  ELSE 2
              END AS WarehouseRank
            , CASE
                  
                  WHEN TE.ExpiryDate IS NULL
                      THEN CAST(1.000000 AS decimal(19,6))
                  
                  WHEN TE.CreatedDate IS NULL
                      THEN CAST(0.000000 AS decimal(19,6))
                  
                  WHEN CONVERT(date, TE.ExpiryDate)
                       <= CONVERT(date, TE.CreatedDate)
                      THEN CAST(0.000000 AS decimal(19,6))
                  ELSE
                      CAST
                      (
                          DATEDIFF
                          (
                                DAY
                              , @Today
                              , CONVERT(date, TE.ExpiryDate)
                          )
                          AS decimal(19,6)
                      )
                      /
                      NULLIF
                      (
                          DATEDIFF
                          (
                                DAY
                              , CONVERT(date, TE.CreatedDate)
                              , CONVERT(date, TE.ExpiryDate)
                          )
                        , 0
                      )
              END AS ShelfLifeRemaining
        FROM dbo.TrackingEntity TE
        INNER JOIN dbo.[Location] L
            ON L.ID = TE.Location_id
        WHERE TE.MasterItem_id = @MasterItemID
          AND TE.Qty <> 0
          AND ISNULL(TE.OnHold, 0) <> 1
          AND TE.InStock = 1
          AND
          (
              ISNULL(@ExcludeBarcode, '') = ''
              OR TE.Barcode <> @ExcludeBarcode
          )
          AND
          (
              TE.ExpiryDate IS NULL
              OR CONVERT(date, TE.ExpiryDate) >= @Today
          )
          AND EXISTS
          (
              SELECT 1
              FROM dbo.OptionalFieldValues_Location OFVL
              WHERE OFVL.BelongsTo_id = L.ID
                AND UPPER(LTRIM(RTRIM(ISNULL(OFVL.[Value], '')))) = 'YES'
          )
    ),
    ShelfLifePreference AS
    (
        SELECT
              BE.*
            , CASE
                  
                  WHEN BE.ShelfLifeRemaining >= 0.75
                      THEN 1
                  
                  
                  ELSE 2
              END AS ShelfLifePreferenceRank
            , MAX
              (
                  CASE
                      WHEN BE.ShelfLifeRemaining >= 0.75
                          THEN 1
                      ELSE 0
                  END
              ) OVER () AS HasAbove75
        FROM BaseEligible BE
    )
    INSERT INTO @Eligible
    (
          Barcode
        , Qty
        , Batch
        , SerialNumber
        , CreatedDate
        , ExpiryDate
        , LocationName
        , CanFulfillOrder
        , SizeRank
        , DifferenceQty
        , WarehouseRank
        , ShelfLifeRemaining
        , ShelfLifePreferenceRank
    )
    SELECT
          SLP.Barcode
        , SLP.Qty
        , SLP.Batch
        , SLP.SerialNumber
        , SLP.CreatedDate
        , SLP.ExpiryDate
        , SLP.LocationName
        , SLP.CanFulfillOrder
        , SLP.SizeRank
        , SLP.DifferenceQty
        , SLP.WarehouseRank
        , SLP.ShelfLifeRemaining
        , SLP.ShelfLifePreferenceRank
    FROM ShelfLifePreference SLP
    WHERE
        (
            
            SLP.HasAbove75 = 1
            AND SLP.ShelfLifeRemaining >= 0.75
        )
        OR
        (
            
            SLP.HasAbove75 = 0
        );
    
    
    
    
    
    
    
    DECLARE @BestNormalCreatedDate datetime;
    SELECT TOP (1)
        @BestNormalCreatedDate = E.CreatedDate
    FROM @Eligible E
    WHERE ISNULL(LTRIM(RTRIM(E.SerialNumber)), '') <> 'ExpiryDate extended'
    ORDER BY
          E.ShelfLifePreferenceRank ASC
        , CASE
              WHEN E.ShelfLifePreferenceRank = 2
                  THEN ABS(E.ShelfLifeRemaining - 0.75)
              ELSE 0
          END ASC
        , E.WarehouseRank ASC
        , E.SizeRank ASC
        , E.CanFulfillOrder DESC
        , CASE
              WHEN E.Qty >= ISNULL(@RequiredQty, 0)
                  THEN E.Qty
              ELSE NULL
          END ASC
        , CASE
              WHEN E.Qty < ISNULL(@RequiredQty, 0)
                  THEN E.Qty
              ELSE NULL
          END DESC
        , CASE
              WHEN E.ExpiryDate IS NULL THEN 1
              ELSE 0
          END ASC
        , E.ExpiryDate ASC
        , E.CreatedDate ASC
        , E.Barcode ASC;
    
    
    
    IF EXISTS
    (
        SELECT 1
        FROM @Eligible
    )
    BEGIN
        ;WITH ScoredRecommendations AS
        (
            SELECT
                  E.Barcode
                , E.Qty
                , E.Batch
                , E.SerialNumber
                , E.CreatedDate
                , E.ExpiryDate
                , E.LocationName
                , E.CanFulfillOrder
                , E.SizeRank
                , E.DifferenceQty
                , E.WarehouseRank
                , E.ShelfLifeRemaining
                , E.ShelfLifePreferenceRank
                , CASE
                      WHEN LTRIM(RTRIM(ISNULL(E.SerialNumber, '')))
                           = 'ExpiryDate extended'
                       AND @BestNormalCreatedDate IS NOT NULL
                       AND E.CreatedDate < @BestNormalCreatedDate
                          THEN 0
                      ELSE 1
                  END AS ExtendedExpiryRank
            FROM @Eligible E
        ),
        RankedRecommendations AS
        (
            SELECT
                  ROW_NUMBER() OVER
                  (
                      ORDER BY
                            SR.ShelfLifePreferenceRank ASC
                          
                          
                          , CASE
                                WHEN SR.ShelfLifePreferenceRank = 2
                                    THEN ABS(SR.ShelfLifeRemaining - 0.75)
                                ELSE 0
                            END ASC
                          , SR.ExtendedExpiryRank ASC
                          , SR.WarehouseRank ASC
                          , SR.SizeRank ASC
                          , SR.CanFulfillOrder DESC
                          , CASE
                                WHEN SR.Qty >= ISNULL(@RequiredQty, 0)
                                    THEN SR.Qty
                                ELSE NULL
                            END ASC
                          , CASE
                                WHEN SR.Qty < ISNULL(@RequiredQty, 0)
                                    THEN SR.Qty
                                ELSE NULL
                            END DESC
                          , CASE
                                WHEN SR.ExpiryDate IS NULL THEN 1
                                ELSE 0
                            END ASC
                          , SR.ExpiryDate ASC
                          , SR.CreatedDate ASC
                          , SR.Barcode ASC
                  ) AS RecommendationRank
                , SR.Barcode
                , SR.Qty
                , SR.Batch
                , SR.ExpiryDate
                , SR.LocationName
            FROM ScoredRecommendations SR
        )
        SELECT TOP (@TopCount)
              CAST(RR.RecommendationRank AS int) AS RecommendationRank
            , RR.Barcode
            , RR.Qty
            , RR.Batch
            , RR.ExpiryDate
            , RR.LocationName
            , CAST(NULL AS nvarchar(MAX)) AS StatusMessage
        FROM RankedRecommendations RR
        ORDER BY RR.RecommendationRank;
        RETURN;
    END;
    
    
    
    DECLARE
          @MachineLocationName    varchar(100)
        , @MachineLocationBarcode varchar(100)
        , @StatusMessage          nvarchar(MAX);
    SELECT TOP (1)
          @MachineLocationName    = L.[Name]
        , @MachineLocationBarcode = L.Barcode
    FROM dbo.TrackingEntity TE
    INNER JOIN dbo.[Location] L
        ON TE.Location_id = L.ID
    WHERE TE.MasterItem_id = @MasterItemID
      AND TE.Qty <> 0
      AND TE.InStock = 1
      AND L.[Name] LIKE '%MACHINE%'
    ORDER BY
          CASE
              WHEN ISNULL(@RequiredQty, 0) > 0
               AND TE.Qty >= @RequiredQty
                  THEN 0
              ELSE 1
          END
        , TE.Qty DESC
        , L.[Name]
        , TE.CreatedDate
        , TE.Barcode;
    IF ISNULL(@MachineLocationName, '') <> ''
    BEGIN
        SET @StatusMessage = CONCAT
        (
              'There is stock on machine '
            , ISNULL(@MachineLocationBarcode, @MachineLocationName)
            , '. Please move it before you can scan it.'
        );
    END;
    ELSE
    BEGIN
        SET @StatusMessage = 'No STOCK available!';
    END;
    
    
    
    SELECT
          CAST(0 AS int) AS RecommendationRank
        , CAST(NULL AS varchar(50)) AS Barcode
        , CAST(NULL AS decimal(19,6)) AS Qty
        , CAST(NULL AS varchar(50)) AS Batch
        , CAST(NULL AS datetime) AS ExpiryDate
        , CAST(NULL AS varchar(100)) AS LocationName
        , @StatusMessage AS StatusMessage;
END;
