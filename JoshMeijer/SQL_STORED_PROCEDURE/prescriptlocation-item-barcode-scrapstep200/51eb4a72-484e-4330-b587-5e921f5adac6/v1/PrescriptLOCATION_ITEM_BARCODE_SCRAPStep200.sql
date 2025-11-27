CREATE PROCEDURE [dbo].[PrescriptLOCATION_ITEM_BARCODE_SCRAPStep200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS


DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )

SET NOCOUNT ON;

DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 

DECLARE @User_Name varchar (40)
DECLARE @User_id bigint
DECLARE @Scrapped_TrackingEntity_id varchar (50)

SELECT @User_Name = value FROM @input WHERE Name = 'User'
SELECT @User_id = ID FROM Users WHERE [Name] = @User_Name
SELECT @Scrapped_TrackingEntity_id = (SELECT TOP 1 TrackingEntity_id FROM [Transaction] WHERE Process = 'LOCATION_ITEM_BARCODE_SCRAP' AND [Type] = 'REPLENISH' AND [User_id] = @User_id ORDER BY ID DESC)

UPDATE TrackingEntity SET InStock = 0 WHERE ID = @Scrapped_TrackingEntity_id

	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput

	SELECT * FROM @Output
