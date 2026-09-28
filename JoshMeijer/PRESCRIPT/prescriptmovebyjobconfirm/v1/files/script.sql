
CREATE PROCEDURE [dbo].[PrescriptMovebyjobConfirm] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid					bit
DECLARE @message				varchar(MAX)
DECLARE @stepInput				varchar(MAX) 
DECLARE @userName				nvarchar(max)
DECLARE @inventoryIdentifier	nvarchar(max)
DECLARE @locationIdentifier		nvarchar(max)
DECLARE @comment				nvarchar(max)
DECLARE @reference				nvarchar(max)
DECLARE @integrationReference	nvarchar(max)
DECLARE @processName			nvarchar(max)
DECLARE @success				bit
DECLARE @fromlocation			varchar(50)
DECLARE @document				varchar(50)
DECLARE @confirm				varchar(50)
DECLARE @recordcount			varchar(50)
DECLARE @barcodestomove			TABLE (ID BIGINT IDENTITY, inventoryIdentifier VARCHAR(50))
SELECT @stepInput			= Value FROM @input WHERE Name = 'StepInput' 
SELECT @locationIdentifier	= value FROM @input WHERE Name = 'Location'
SELECT @document			= value FROM @input WHERE Name = 'Document'
SELECT @confirm				= value FROM @input WHERE Name = 'Confirm'
SELECT @userName			= Value FROM @input WHERE Name = 'User'      
IF @locationIdentifier = 'Started'
BEGIN
	SET @fromlocation = 'NotStarted'
END
ELSE IF @locationIdentifier = 'READYFORPRODUCTION'
BEGIN
	SET @fromlocation = 'Started'
END
INSERT INTO @barcodestomove (inventoryIdentifier)
SELECT DISTINCT TE.Barcode
FROM [Location] L INNER JOIN TrackingEntity TE ON L.ID = TE.Location_id
WHERE TE.Batch = @document
AND L.Barcode = @fromlocation
IF @confirm <> 'YES'
BEGIN
	SELECT @recordcount = 0, @message = 'CANCELLED', @valid = 1
END
ELSE
BEGIN
	SELECT @recordcount = MAX(ID) FROM @barcodestomove
END
WHILE @recordcount > 0
BEGIN
	
	SELECT @inventoryIdentifier = inventoryIdentifier FROM @barcodestomove WHERE ID = @recordcount
	SET @recordcount -= 1
	
	EXECUTE [dbo].[clr_Move] 
	   @userName
	  ,@inventoryIdentifier
	  ,@locationIdentifier
	  ,@comment
	  ,@reference
	  ,@integrationReference
	  ,@processName
	  ,@success OUTPUT
	  ,@message OUTPUT
	  EXEC [dbo].[custom_post_to_EVOApp] @inventoryIdentifier
END
	
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
