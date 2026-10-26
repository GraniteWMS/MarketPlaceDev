CREATE PROCEDURE [dbo].[PrescriptTransferPostDocument] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = ''
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @DocumentNumber         VARCHAR(30)
DECLARE @DocumentID             BIGINT
DECLARE @ToWarehouseLocation    VARCHAR(30)
DECLARE @SageWarehouseNotLinked VARCHAR(500)
DECLARE @SageDocumentID         VARCHAR(50)
DECLARE @IBTStatus              INT
DECLARE @MatchedOn              VARCHAR(20)
SELECT @DocumentNumber = @stepInput
SELECT 
    @DocumentID = D.ID
FROM Document D
WHERE D.Number = @DocumentNumber
IF @DocumentID IS NULL
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - Document does not exists***'
    GOTO ScriptEnd
END
SELECT TOP 1
    @SageDocumentID = W.IDWhseIBT,
    @IBTStatus      = W.iIBTStatus,
    @MatchedOn      = CASE 
                        WHEN W.cIBTNumber = @DocumentNumber THEN 'cIBTNumber'
                        WHEN W.cDelNoteNumber = @DocumentNumber THEN 'cDelNoteNumber'
                      END
FROM [Cranbrook Flavours].dbo._etblWhseIBT W WITH (NOLOCK)
WHERE W.cIBTNumber = @DocumentNumber
   OR W.cDelNoteNumber = @DocumentNumber
IF @SageDocumentID IS NULL
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - No matching Sage IBT document found***'
    GOTO ScriptEnd
END
IF @IBTStatus = 2
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - Sage IBT document is closed***'
    GOTO ScriptEnd
END
IF @IBTStatus = 0 AND @MatchedOn <> 'cIBTNumber'
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - IBTStatus = 0, document must be posted using the IBT number***'
    GOTO ScriptEnd
END
IF @IBTStatus = 1 AND @MatchedOn <> 'cDelNoteNumber'
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - IBTStatus = 1, document must be posted using the delivery note number***'
    GOTO ScriptEnd
END
SELECT TOP 1
    @ToWarehouseLocation =
        CASE 
            WHEN D.Number LIKE '%IBT%'  THEN DD.IntransitLocation
            WHEN D.Number LIKE '%IDEL%' THEN DD.ToLocation
        END
FROM Document D
INNER JOIN DocumentDetail DD
    ON D.ID = DD.Document_id
WHERE D.Number = @DocumentNumber
IF NOT EXISTS
(
    SELECT 1
    FROM [Transaction] T
    WHERE T.Document_id = @DocumentID
      AND T.IntegrationStatus = 0
)
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - No Outstanding Integration***'
    GOTO ScriptEnd
END
IF EXISTS
(
    SELECT 1
    FROM ERP_StockOnHand SOH
    INNER JOIN
    (
        SELECT 
            RAT.Code,
            RAT.FromLocationERP,
            SUM(RAT.ActionQty) AS TransactionQTY
        FROM Report_App_Transactions RAT
        WHERE RAT.DocumentNumber = @DocumentNumber
          AND RAT.TransactionType = 'TRANSFER'
          AND ISNULL(RAT.IntegrationReference, '') = ''
        GROUP BY RAT.Code, RAT.FromLocationERP
    ) TSQL
        ON TSQL.Code = SOH.ITEMNO
       AND TSQL.FromLocationERP = SOH.LOCATION
    WHERE TSQL.TransactionQTY > SOH.QtyOnHand
)
BEGIN
    SET @valid = 0
    SET @message = '***ERROR - Insufficient stock in Sage to complete the transaction.***'
    GOTO ScriptEnd
END
;WITH GraniteDocumentDetail AS
(
    SELECT DISTINCT
        MI.Code,
        CASE 
            WHEN D.Number LIKE '%IBT%'  THEN DD.IntransitLocation
            WHEN D.Number LIKE '%IDEL%' THEN DD.ToLocation
        END AS ToLocation
    FROM Document D
    INNER JOIN DocumentDetail DD
        ON D.ID = DD.Document_id
    INNER JOIN MasterItem MI
        ON DD.Item_id = MI.ID
    WHERE D.Number = @DocumentNumber
),
SageWarehouseLink AS
(
    SELECT DISTINCT
        SI.Code,
        WM.Code AS WarehouseCode
    FROM [Cranbrook Flavours].dbo._etblStockDetails SD
    INNER JOIN [Cranbrook Flavours].dbo.StkItem SI
        ON SD.StockID = SI.StockLink
    INNER JOIN [Cranbrook Flavours].dbo.WhseMst WM
        ON SD.WhseID = WM.WhseLink
)
SELECT 
    @SageWarehouseNotLinked =
        ISNULL(
            STUFF
            (
                (
                    SELECT DISTINCT ', ' + GDD.Code
                    FROM GraniteDocumentDetail GDD
                    WHERE NOT EXISTS
                    (
                        SELECT 1
                        FROM SageWarehouseLink SWL
                        WHERE SWL.Code = GDD.Code
                          AND SWL.WarehouseCode = GDD.ToLocation
                    )
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)')
            ,1,2,'')
        ,'')
IF ISNULL(@SageWarehouseNotLinked, '') <> ''
BEGIN
    SET @valid = 0
    SET @message = CONCAT('Items ', @SageWarehouseNotLinked, ' not linked to warehouse ', @ToWarehouseLocation)
    GOTO ScriptEnd
END
ScriptEnd:
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
