CREATE PROCEDURE [dbo].[PreScript_Manufacture_Document] (
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
DECLARE @User varchar(30)
SELECT @User = Value FROM @input WHERE Name = 'User'
IF EXISTS (SELECT 1 FROM Document WHERE Number = @stepInput)
BEGIN
    DECLARE @completion DECIMAL(10,2);
    SELECT @completion = 
        (SUM(CASE WHEN DocumentDetail.Qty = 0 THEN 0 ELSE DocumentDetail.ActionQty END) 
         / NULLIF(SUM(DocumentDetail.Qty), 0)) * 100
    FROM Document
    INNER JOIN DocumentDetail
        ON Document.ID = DocumentDetail.Document_id
    WHERE 
        Document.Number = @stepInput
        AND DocumentDetail.Type = 'INPUT'
		AND DocumentDetail.LineNumber <> '8888'
    GROUP BY DocumentDetail.Document_id;
    IF @completion IS NULL
    BEGIN
        SELECT @valid = 0;
        SELECT @message = 'No valid INPUT lines found on document.';
    END
	ELSE IF @User IN ('0', 'NKAGE', 'NKAGER', 'SIPHIWE', 'CONOR','SEAN','SBONISO','ZITHOBILE')
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'User Allowed'
	END
    ELSE IF @completion >= 100
    BEGIN
        SELECT @valid = 1;
        SELECT @message = CONCAT('Raw material picking is 100% complete (', FORMAT(@completion, 'N2'), '%).');
    END
    ELSE IF @completion >= 95
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Picking is ', FORMAT(@completion, 'N2'), '% complete. Please ensure all materials are picked before final labeling.');
    END
    ELSE
    BEGIN
        SELECT @valid = 0;
        SELECT @message = CONCAT('Picking of raw materials is only ', FORMAT(@completion, 'N2'), 
                                 '%. Must be at least 100% complete before printing the finished goods label.');
    END
END
ELSE
BEGIN
    SELECT @valid = 0;
    SELECT @message = CONCAT('Invalid document number: ', UPPER(@stepInput));
END
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
