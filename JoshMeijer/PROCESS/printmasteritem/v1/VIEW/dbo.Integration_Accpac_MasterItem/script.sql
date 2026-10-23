CREATE VIEW [dbo].[Integration_Accpac_MasterItem] as
SELECT
    RTRIM(I.[ITEMNO]) COLLATE Latin1_General_CI_AS                    AS Code,
    RTRIM(I.[FMTITEMNO]) COLLATE Latin1_General_CI_AS                 AS FormattedCode,
    RTRIM(I.[DESC]) COLLATE Latin1_General_CI_AS                      AS [Description],
    RTRIM(I.[STOCKUNIT]) COLLATE Latin1_General_CI_AS                 AS UOM,
    CAST(~I.[INACTIVE] AS bit)                                        AS isActive,
    RTRIM(I.[CATEGORY]) COLLATE Latin1_General_CI_AS                  AS Category,
    I.[LEXPDAYS]                                                      AS ShelfLife,
    CAST(I.[UNITWGT] AS DECIMAL(19,2))                                AS UnitWeight,
    I.[SERIALNO]                                                      AS EnforceSerialNumber,
    I.[LOTITEM]                                                       AS EnforceBatchNumber,
    I.[LOTITEM]                                                       AS EnforceExpiryDate,
    RTRIM(I.[FMTITEMNO]) COLLATE Latin1_General_CI_AS                 AS ERPIdentification,
    RTRIM(O.[LATEST]) COLLATE Latin1_General_CI_AS                    AS [LATEST],
    ISNULL(NULLIF(RTRIM(O.[PACK]), ''), '1') COLLATE Latin1_General_CI_AS AS [PACK]
FROM [PINDAT].dbo.[ICITEM] I
LEFT JOIN
(
    SELECT
        RTRIM(ITEMNO) COLLATE Latin1_General_CI_AS AS ITEMNO,
        MAX(CASE WHEN OPTFIELD = 'LATEST' THEN VALUE END) AS [LATEST],
        MAX(CASE WHEN OPTFIELD = 'PACK'   THEN VALUE END) AS [PACK]
    FROM [PINDAT].dbo.[ICITEMO]
    WHERE OPTFIELD IN ('LATEST', 'PACK')
    GROUP BY RTRIM(ITEMNO) COLLATE Latin1_General_CI_AS
) O
    ON RTRIM(I.[ITEMNO]) COLLATE Latin1_General_CI_AS = O.ITEMNO;
