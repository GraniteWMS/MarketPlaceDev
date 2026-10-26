CREATE PROCEDURE [dbo].[SSRS_TransferSheet_Header]
    @DocumentNumber NVARCHAR(50)
AS
BEGIN
	SELECT TOP 1 Integration_Accpac_TransferHeader.Number as DocumentNumber, Integration_Accpac_TransferHeader.CreateDate,
	Integration_Accpac_TransferHeader.ERPLocation as FromLocation,
	Integration_Accpac_TransferHeader.[Description], Integration_Accpac_TransferHeader.ExpectedDate,Document.RouteName,Document.StopName,
	(SELECT TOP 1 ToLocation FROM DocumentDetail WHERE Document_id = Document.ID) AS DestinationLocation
	FROM Integration_Accpac_TransferHeader
	INNER JOIN Document ON Integration_Accpac_TransferHeader.Number COLLATE SQL_Latin1_General_CP1_CI_AS = Document.Number
	 WHERE Integration_Accpac_TransferHeader.Number =@DocumentNumber  
END
