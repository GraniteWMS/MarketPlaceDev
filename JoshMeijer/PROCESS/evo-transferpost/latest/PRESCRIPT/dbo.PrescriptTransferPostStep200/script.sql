CREATE PROCEDURE [dbo].[PrescriptTransferPostStep200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit= 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @DocumentNumber         VARCHAR(30)
DECLARE @DelNumber              VARCHAR(30)
DECLARE @UserName               VARCHAR(30)
DECLARE @UserID                 BIGINT
DECLARE @IntegrationReference   VARCHAR(30)
DECLARE @DocumentID             BIGINT
DECLARE @FromLocation           VARCHAR(30)
DECLARE @NextNo                 BIGINT
DECLARE @IsIBT                  BIT = 0
DECLARE @IsIDEL                 BIT = 0
SELECT @UserName = Value
FROM @input
WHERE Name = 'User'
SELECT @DocumentNumber = Value
FROM @input
WHERE Name = 'Document'
SELECT @UserID = U.ID
FROM Users U
WHERE U.Name = @UserName
SELECT 
      @DocumentID = D.ID
    , @FromLocation = D.ERPLocation
FROM Document D
WHERE D.Number = @DocumentNumber
IF @DocumentNumber LIKE '%IBT%'
    SET @IsIBT = 1
IF @DocumentNumber LIKE '%IDEL%'
    SET @IsIDEL = 1
SELECT TOP (1)
    @IntegrationReference = T.IntegrationReference
FROM [Transaction] T
WHERE T.Document_id = @DocumentID
  
  AND T.Type = 'Transfer'
  AND ISNULL(T.IntegrationReference, '') <> ''
  AND T.IntegrationStatus = 1
ORDER BY T.ID DESC
IF @IsIBT = 1
BEGIN
    BEGIN TRAN
    SELECT @NextNo = RB.iNextNo
    FROM [Cranbrook Flavours].dbo._rtblRefBase RB WITH (UPDLOCK, HOLDLOCK)
    WHERE RB.cRefType = 'NextWHIBTDelNote'
    SELECT @DelNumber = CONCAT('12_ITE_IDEL', @NextNo)
    UPDATE RB
       SET RB.iNextNo = RB.iNextNo + 1
    FROM [Cranbrook Flavours].dbo._rtblRefBase RB
    WHERE RB.cRefType = 'NextWHIBTDelNote'
    UPDATE W
       SET W.iIBTStatus         = 1
         , W.cDelNoteNumber     = @DelNumber
         , W.cAuditNumberIssued = @IntegrationReference
    FROM [Cranbrook Flavours].dbo._etblWhseIBT W
    WHERE W.cIBTNumber = @DocumentNumber
    UPDATE D
       SET D.[Status] = 'COMPLETE'
    FROM Document D
    WHERE D.ID = @DocumentID
    COMMIT TRAN
END
IF @IsIDEL = 1
BEGIN
    UPDATE W
       SET W.iIBTStatus           = 2
         , W.cAuditNumberReceived = @IntegrationReference
    FROM [Cranbrook Flavours].dbo._etblWhseIBT W
    WHERE W.cDelNoteNumber = @DocumentNumber
    UPDATE D
       SET D.[Status] = 'COMPLETE'
    FROM Document D
    WHERE D.ID = @DocumentID
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
