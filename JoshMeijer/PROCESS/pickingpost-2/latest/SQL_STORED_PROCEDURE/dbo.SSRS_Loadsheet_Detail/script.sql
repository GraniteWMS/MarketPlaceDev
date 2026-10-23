CREATE PROCEDURE [dbo].[SSRS_Loadsheet_Detail]
    @DocumentNumber NVARCHAR(50),@Shipment NVARCHAR(50)
AS
BEGIN
SELECT 
   * FROM [Loadsheet_Detail]
	WHERE DocumentNumber = @DocumentNumber
    ORDER BY Line,[Item Code], Batch
END
