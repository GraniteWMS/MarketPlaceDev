CREATE PROCEDURE [dbo].[SSRS_Loadsheet_Header]
    @DocumentNumber NVARCHAR(50), @Shipment NVARCHAR(50)
AS
BEGIN
	SELECT TOP 1 Information_Accpac_SalesOrderHeader.Number as DocumentNumber, Information_Accpac_SalesOrderHeader.CreateDate,
	Information_Accpac_SalesOrderHeader.TradingPartnerCode,
	Information_Accpac_SalesOrderHeader.TradingPartnerDescription, Information_Accpac_SalesOrderHeader.ExpectedDate,
	SHIPNAME, SHPADDR1, SHPADDR2, SHPADDR3, SHPADDR4, SHPCITY, SHPCONTACT, SHPCOUNTRY, SHPZIP, TERMS, SHIPVIA, VIADESC, 
	Information_Accpac_SalesOrderHeader.Description,Document.RouteName,Document.StopName,
	Information_Accpac_SalesOrderHeader.Shipment,
	PONumber, 
	Information_Accpac_SalesOrderHeader.SHPPHONE
	FROM Information_Accpac_SalesOrderHeader INNER JOIN Document ON Information_Accpac_SalesOrderHeader.Number = Document.Number
	 WHERE Information_Accpac_SalesOrderHeader.Number =@DocumentNumber  
	 ORDER BY Information_Accpac_SalesOrderHeader.Shipment DESC
	
END
