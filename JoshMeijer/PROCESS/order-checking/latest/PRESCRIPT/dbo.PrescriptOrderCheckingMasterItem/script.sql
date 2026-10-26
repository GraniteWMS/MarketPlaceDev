CREATE PROCEDURE [dbo].[PrescriptOrderCheckingMasterItem] (
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



DECLARE @User varchar(30)
DECLARE @Document varchar(30)
DECLARE @Document_id bigint
DECLARE @ProcessName varchar(50)

SELECT @ProcessName = [Value] 
FROM SystemStaticData 
WHERE [Group] = 'ProcessName' AND [Key] = 'ORDER_CHECKING'

SELECT @User = [Value] FROM @input WHERE [Name] = 'User'
SELECT @Document = [Value] FROM @input WHERE [Name] = 'Document'
SELECT @Document_id = ID FROM Document WHERE Number = @Document

SELECT @valid = 1

IF @stepInput = 'REFRESH'
BEGIN
	DELETE FROM ProcessStepLookupDynamic
	WHERE Process = @ProcessName AND ProcessStep = 'MasterItem' AND UserName = @User

	INSERT INTO ProcessStepLookupDynamic (Value, Description, Process, ProcessStep, UserName)
	SELECT MasterItem.Code, CONCAT('Item: ',Code, ' ', MasterItem.Description, ' Qty: ', SUM(ISNULL(ActionQty, 0)) - SUM(ISNULL(PackedQty, 0))), @ProcessName, 'MasterItem', @User
	FROM DocumentDetail INNER JOIN
	MasterItem ON DocumentDetail.Item_id = MasterItem.ID
	WHERE Document_id = @Document_id
	GROUP BY Code, Description
	HAVING SUM(ISNULL(ActionQty, 0)) - SUM(ISNULL(PackedQty, 0)) > 0

	SELECT @valid = 0
	SELECT @message = 'REFRESHED'
END





	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
