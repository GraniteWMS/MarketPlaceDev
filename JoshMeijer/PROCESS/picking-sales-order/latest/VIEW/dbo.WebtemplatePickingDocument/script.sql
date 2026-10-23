CREATE VIEW [dbo].[WebtemplatePickingDocument]
AS
WITH RankedDocuments AS (
    SELECT
        Number,
        FORMAT(CreateDate, 'dd/MM/yyyy hh:mm') AS Date,
        TradingPartnerCode AS TPCode,
        TradingPartnerDescription AS TPDescription,
        ROW_NUMBER() OVER (PARTITION BY TradingPartnerCode ORDER BY CreateDate ASC) AS RowNum
    FROM (
        SELECT TOP 1000
            Number,
            CreateDate,
            TradingPartnerCode,
            TradingPartnerDescription
        FROM
            Document
        WHERE
            [Type] = 'ORDER'
            AND [Status] IN ('ENTERED', 'RELEASED')
        ORDER BY
            TradingPartnerCode, CreateDate ASC
    ) AS TopDocuments
)
SELECT
    Number,
    Date,
    TPCode,
    TPDescription
FROM
    RankedDocuments
WHERE
    RowNum <= 100
