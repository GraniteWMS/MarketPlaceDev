
CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_Step201] (
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
DECLARE @Success bit
DECLARE @stepInput varchar(MAX) 
DECLARE @CarryingEntity varchar(50) = (SELECT Value FROM @input WHERE Name = 'Palletbarcode')
DECLARE @MasterItem varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @QtyMade varchar(20) = (SELECT Value FROM @input WHERE Name = 'Qty')
DECLARE @dQtyMade decimal(19,4) = CONVERT(Decimal(19,4),@QtyMade)
DECLARE @UserName varchar(50) = (SELECT [Value] FROM @input WHERE Name = 'User')
DECLARE @userID bigint
DECLARE @Site varchar(50)
DECLARE @Location varchar(50) = 'CCF-PKG-WIP'
SELECT @userID = ID, @Site = [Site] FROM Users WHERE Name = @UserName
IF isnull(@userID,0) = 0 SELECT @userID = 3
IF isnull(@Site,'') = '' SELECT @Site =  'CCF'
DECLARE @printerName nvarchar(max) =  (SELECT RTRIM(UPPER(Value)) FROM @input WHERE Name = 'PrinterName')
EXEC Utility_ConsumeInputsfromWIP @MasterItem, @Site, @Location, @CarryingEntity,@dQtyMade, @UserName,@Success
If @Success = 1
BEGIN
	SELECT @Valid = 1, @message = 'Raw material consumption done'
	INSERT INTO custom_LogMessages (Message,Date)
	SELECT CONCAT('Pallet:', @CarryingEntity, ' Location:',@Location, ' Qty Made:',@QtyMade,'Raw material Consumption Done'), getdate()
	
END
ELSE
BEGIN
	SELECT @Valid = 1, @message = 'Raw material consumption failed'
	INSERT INTO custom_LogMessages (Message,Date)
	SELECT CONCAT('Pallet:', @CarryingEntity, ' Location:',@Location, ' Qty Made:',@QtyMade,'Raw material Consumption Failed'), getdate()
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
