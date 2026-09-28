CREATE PROCEDURE [dbo].[Prescript_Generic_Document_UpdateInstruction] (
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
DECLARE @Document_id bigint
SELECT @Document_id = ID FROM Document WHERE Number = @stepInput
IF ISNULL(@Document_id, 0) = 0
BEGIN
	SELECT @valid = 0
	SELECT @message = CONCAT('Document ', @stepinput, ' not found')
END
ELSE
BEGIN
	UPDATE DocumentDetail
	SET Instruction = CONCAT('Revert to manager: ', tbl.[Message])
	FROM DocumentDetail OUTER APPLY
	(
		SELECT TOP 1 [Message]
		FROM IntegrationLog
		WHERE DocumentDetail_id = DocumentDetail.ID
		ORDER BY [Date] DESC
	) tbl
	WHERE DocumentDetail.Document_id = @Document_id AND DocumentDetail.ERPSyncFailed = 1
	SELECT @valid = 1
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
