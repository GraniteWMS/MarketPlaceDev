CREATE PROCEDURE [dbo].[WebTemplate_PackingCustom_PackDetail]
    @Document varchar(100)
AS
BEGIN
 SET NOCOUNT ON;
    SELECT
          MI.Code          AS ItemCode
        , MI.[Description] AS [Description]
        , SUM(T.ActionQty) AS QtyPacked
    FROM dbo.CarryingEntity CE
    INNER JOIN dbo.[Transaction] T
        ON T.ToContainableEntity_id = CE.ID
    INNER JOIN dbo.MasterItem MI
        ON MI.ID = T.FromMasterItem_id
    WHERE CE.Barcode LIKE @Document + '%'
      AND T.[Type] = 'PACK'
      AND ISNULL(T.ReversalTransaction_id, 0) = 0
    GROUP BY
          MI.Code
        , MI.[Description]
    ORDER BY
          MI.Code;
END
