
CREATE PROCEDURE [dbo].[Utility_GenerateMixDocument]
	@OutputItemNumber varchar(30)
	,@LoopCount int
	,@StartBarcode int
	,@valid bit OUTPUT
	,@message varchar(MAX) OUTPUT
AS

DECLARE @OutputItemQty decimal(19, 4) = (SELECT SUM(QTY) FROM Custom_BomDetails WHERE MIXCODE = @OutputItemNumber AND UNIT IN ('KG', 'LT') AND ISNULL(ISWETCODE, '') <> 'YES')
DECLARE @OutputItem_id bigint = (SELECT ID FROM MasterItem WHERE Code = @OutputItemNumber)

DECLARE @InsertedDocuments TABLE (
	Document_id bigint,
	DocumentNumber varchar(50)
)

BEGIN TRY

	;WITH Tally AS (
		SELECT TOP (@LoopCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
		FROM sys.all_objects
	),
	Barcodes AS (
		SELECT
		rn
		,@StartBarcode + rn - 1 AS BarcodeValue
		,RIGHT('000000' + CAST(@StartBarcode + rn - 1 AS varchar(6)), 6) AS PaddedBarcode
		FROM Tally
	),
	NewDocuments AS (
		SELECT
		CONCAT(@OutputItemNumber, '-', PaddedBarcode) AS DocumentNumber
		,GETDATE() AS CreateDate
		,rn
		FROM Barcodes
	)

	INSERT INTO Document (
		Number
		,[Type]
		,[Status]
		,CreateDate
		,isActive
		,ERPLocation
		,[Site]
		,AuditDate
		,AuditUser
		,[Version]
	)
	OUTPUT INSERTED.ID, INSERTED.Number INTO @InsertedDocuments (Document_id, DocumentNumber)
	SELECT 
	nd.DocumentNumber,
	'WORKORDER',
	'ENTERED',
	nd.CreateDate,
	1,
	'PIE',
	'',
	nd.CreateDate,
	'AUTOMATION',
	1
	FROM NewDocuments nd

	INSERT INTO IntegrationDocumentQueue (
		ERP_id
		,DocumentNumber
		,DocumentType
		,[Status]
	)
	SELECT
	Document_id
	,DocumentNumber
	,'WORKORDER'
	,'READY'
	FROM @InsertedDocuments

	INSERT INTO DocumentDetail (
		Document_id
		,Item_id
		,LineNumber
		,Qty
		,UOM
		,FromLocation
		,ToLocation
		,[Type]
	)
	SELECT
	Document_id
	,@OutputItem_id
	,0
	,@OutputItemQty
	,'EACH'
	,'PIE'
	,'PIE'
	,'OUTPUT'
	FROM @InsertedDocuments

	SELECT @valid = 1
	,@message = 'Mix documents successfully Created'

END TRY
BEGIN CATCH

	SELECT @valid = 0
	,@message = ERROR_MESSAGE()

END CATCH
