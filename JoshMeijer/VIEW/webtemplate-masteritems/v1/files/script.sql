CREATE VIEW [dbo].[WebTemplate_MasterItems]
AS
    SELECT MI.Code, ISNULL(MIA.Code, '') AS Alias, MI.[Description], MI.[Category], ISNULL(dbo.FN_GetCustomerCode(MI.Code, 'MASTERITEM'),'') AS Customer, TP.[Description] AS [Customer Name]
      FROM [MasterItem] MI
 LEFT JOIN [MasterItemAlias] MIA ON MI.ID = MIA.MasterItem_id
 LEFT JOIN TradingPartner TP ON TP.Code = ISNULL(dbo.FN_GetCustomerCode(MI.Code, 'MASTERITEM'),'') AND DocumentType = 'RECEIVING'
	 WHERE MI.isActive = 1
