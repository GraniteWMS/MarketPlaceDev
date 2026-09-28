CREATE VIEW [dbo].[Label_MasterItem]
AS
SELECT
    MI.Code,
	MI.FormattedCode,
    MI.Description,
	MI.UOM AS StockedUOM,
    MI.[Type],
    MI.Category,
    LastPick.DocumentNumber,
    LastPick.TradingPartnerCode,
		LastPick.TradingPartnerDescription,
		LastPick.SHIPNAME,
		LastPick.SHPADDR1,
		LastPick.SHPADDR2,
		LastPick.SHPADDR3,
		LastPick.SHPCITY,
		LastPick.SHPSTATE,
		LastPick.SHPZIP,
		LastPick.SHPCOUNTRY,
		LastPick.CUSTOMERPO,
		LastPick.SHIPVIA,
		LastPick.VIADESC
FROM dbo.MasterItem MI
OUTER APPLY
(
    SELECT TOP 1
        TX.Document_id,
        D.Number AS DocumentNumber,
		SOH.TradingPartnerCode,
		SOH.TradingPartnerDescription,
		SOH.SHIPNAME,
		SOH.SHPADDR1,
		SOH.SHPADDR2,
		SOH.SHPADDR3,
		SOH.SHPCITY,
		SOH.SHPSTATE,
		SOH.SHPZIP,
		SOH.SHPCOUNTRY,
		SOH.CUSTOMERPO,
		SOH.SHIPVIA,
		SOH.VIADESC
    FROM dbo.[Transaction] TX
    LEFT JOIN dbo.Document D
        ON TX.Document_id = D.ID
    LEFT JOIN dbo.Information_ACCPAC_SalesOrderHeader SOH
        ON D.Number = SOH.Number
        
        
    WHERE
        TX.[Type] = 'PICK'
        AND TX.FromMasterItem_id = MI.ID
        AND ISNULL(TX.ReversalTransaction_id, 0) = 0
    ORDER BY
        TX.ID DESC
) LastPick
