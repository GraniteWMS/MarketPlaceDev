CREATE PROCEDURE [dbo].[Utility_PrintPackingList] (@DocumentNumber varchar(50),@sPrinterName varchar(max)) 
AS
BEGIN
	DECLARE @sReportName varchar(max)		                              
	DECLARE @sPrintQty integer			
	DECLARE @sLorP varchar(20)			
	DECLARE @sParm1Name varchar(50)		
	DECLARE @sParm1Value varchar(50)		
	DECLARE @authHeader NVARCHAR(64);
	DECLARE @contentType NVARCHAR(64);
	DECLARE @postData NVARCHAR(2000);
	DECLARE @responseText NVARCHAR(2000);
	DECLARE @responseXML NVARCHAR(2000);
	DECLARE @ret INT;
	DECLARE @status NVARCHAR(32);
	DECLARE @statusText NVARCHAR(32);
	DECLARE @token INT;
	DECLARE @url NVARCHAR(256);
	DECLARE @body varchar(8000)
	DECLARE @PackingListType bit
	SELECT @PackingListType = ISNULL(DROPSHIP,0) FROM ERP_OrderHeader WHERE ORDNUMBER = @DocumentNumber
	SET @sReportName = CASE WHEN @PackingListType = 1 THEN '/PackingListDropship' ELSE '/PackingListStandard' END	
	SET @sPrintQty = 2				
	SET @sLorP = 'Portrait' 
	SET @sParm1Name = 'OrderNumber'
	SET @sParm1Value = @DocumentNumber
	SELECT @body = 'sPrinterName='+@sPrinterName+'&sReportName='+@sReportName+'&sPrintQty='+CONVERT(varchar,@sPrintQty)+'&sLorP='+@sLorP+'&sParm1Name='+@sParm1Name+'&sParm1Value='+@sParm1Value 
	SET @contentType = 'application/x-www-form-urlencoded';
	
	SET @url = 'http://server2:40097/PrintSSRSReport.asmx/Report_1Parm'
	SELECT @body, @url
	
	EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;
	IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);
	
	EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
	EXEC @ret = sp_OAMethod @token, 'send', null, @body
	
	EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
	EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
	EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;
	SELECT @status, @statusText, @responseText
	
	EXEC @ret = sp_OADestroy @token;
	IF @ret <> 0 RAISERROR('Unable to close HTTP connection.', 10, 1);
END
	
	