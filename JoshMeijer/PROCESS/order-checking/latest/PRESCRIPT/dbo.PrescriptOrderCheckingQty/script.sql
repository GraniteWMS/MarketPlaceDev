CREATE PROCEDURE [dbo].[PrescriptOrderCheckingQty] (
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
DECLARE @User_id bigint
DECLARE @Document varchar(30)
DECLARE @Document_id bigint
DECLARE @MasterItem varchar(50)
DECLARE @Location varchar(30)
DECLARE @MasterItem_id bigint
DECLARE @ProcessName varchar(50)

SELECT @ProcessName = [Value] 
FROM SystemStaticData 
WHERE [Group] = 'ProcessName' AND [Key] = 'ORDER_CHECKING'

SELECT @User = [Value] FROM @input WHERE [Name] = 'User'
SELECT @User_id = ID FROM Users WHERE Name = @User
SELECT @Document = [Value] FROM @input WHERE [Name] = 'Document'
SELECT @Location = [Value] FROM @input WHERE [Name] = 'Location'
SELECT @Document_id = ID FROM Document WHERE Number = @Document
SELECT @MasterItem = [Value] FROM @input WHERE [Name] = 'MasterItem'
SELECT @MasterItem_id = ID FROM MasterItem WHERE Code = @MasterItem

IF ISNUMERIC(@stepInput) = 0 
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Qty must be a number'
END
ELSE
BEGIN
	SELECT @valid = 1

	DECLARE @documentNumber nvarchar(max)
	DECLARE @locationBarcode nvarchar(max)
	DECLARE @carryingEntityBarcode nvarchar(max)
	DECLARE @identifierCode nvarchar(max)
	DECLARE @qty numeric(18,0)
	DECLARE @userID bigint
	DECLARE @comment nvarchar(max)
	DECLARE @reference nvarchar(max)
	DECLARE @integrationReference nvarchar(max)
	DECLARE @responseCode int
	DECLARE @responseJSON nvarchar(max)

	SELECT @documentNumber = @Document
	SELECT @locationBarcode = @Location 
	SELECT @carryingEntityBarcode = @Document
	SELECT @identifierCode = @MasterItem
	SELECT @qty = @stepInput
	SELECT @userID = @User_id

	EXECUTE [dbo].[clr_Pack] 
	   @documentNumber
	  ,@locationBarcode
	  ,@carryingEntityBarcode
	  ,@identifierCode
	  ,@qty
	  ,@userID
	  ,@comment
	  ,@ProcessName
	  ,@reference
	  ,@integrationReference
	  ,@responseCode OUTPUT
	  ,@responseJSON OUTPUT

	IF @responseCode <> 200
	BEGIN
		SELECT @valid = 0
		SELECT @message = @responseJSON
	END
	ELSE
	BEGIN
		SELECT @valid = 1
		SELECT @message = 'Successful'
	END


	DELETE FROM ProcessStepLookupDynamic
	WHERE Process = @ProcessName AND ProcessStep = 'MasterItem' AND UserName = @User

	INSERT INTO ProcessStepLookupDynamic (Value, Description, Process, ProcessStep, UserName)
	SELECT MasterItem.Code, CONCAT('Item: ',Code, ' ', MasterItem.Description, ' Qty: ', SUM(ISNULL(ActionQty, 0)) - SUM(ISNULL(PackedQty, 0))), @ProcessName, 'MasterItem', @User
	FROM DocumentDetail INNER JOIN
	MasterItem ON DocumentDetail.Item_id = MasterItem.ID
	WHERE Document_id = @Document_id
	GROUP BY Code, Description
	HAVING SUM(ISNULL(ActionQty, 0)) - SUM(ISNULL(PackedQty, 0)) > 0

END






	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput


	SELECT * FROM @Output
