CREATE PROCEDURE [dbo].[PrescriptCourierPackingBoxType] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @BoxBarcode VARCHAR(100);
DECLARE @BoxTypeCode VARCHAR(50);
DECLARE @AuditUser VARCHAR(50);

SET @BoxTypeCode = LTRIM(RTRIM(ISNULL(@stepInput, '')));

SELECT TOP 1
    @BoxBarcode = LTRIM(RTRIM([Value]))
FROM @input
WHERE [Name] = 'BoxBarcode';

SELECT TOP 1
    @AuditUser = LEFT(CAST([Value] AS VARCHAR(50)), 50)
FROM @input
WHERE [Name] IN ('User');

SET @AuditUser = ISNULL(NULLIF(@AuditUser, ''), 'SYSTEM');


UPDATE CB
SET
      CB.CourierBoxType_id = CBT.ID
    , CB.AuditDate = GETDATE()
    , CB.AuditUser = @AuditUser
    , CB.Version = ISNULL(CB.Version, 0) + 1
FROM dbo.Custom_CourierBox CB
INNER JOIN dbo.Custom_CourierBoxType CBT
    ON CBT.Code = @BoxTypeCode
WHERE CB.BoxBarcode = @BoxBarcode;

SET @message = 'Courier box type updated.';


Finish:
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
