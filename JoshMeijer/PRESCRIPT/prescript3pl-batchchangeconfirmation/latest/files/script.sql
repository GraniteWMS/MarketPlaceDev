CREATE PROCEDURE [dbo].[Prescript3PL_BatchChangeConfirmation] (
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
DECLARE @User varchar(50) = (SELECT Value from @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) 
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @Batch varchar(50) = (SELECT Value FROM @input WHERE Name = 'Batch' )
DECLARE @MasterItem varchar(50) = (SELECT Value FROM @input WHERE Name = 'MasterItem' )
DECLARE @NewBatch varchar(50) = (SELECT Value FROM @input WHERE Name = 'NewBatch' )
DECLARE @MasterItemID bigint = (SELECT ID FROM MasterItem WHERE Code = @MasterItem)
DECLARE @UserId bigint = (SELECT ID FROM [Users] WHERE Name = @User)
IF UPPER(@stepInput) = 'Y' or @stepInput = 'Yes' 
BEGIN
	If isnull(@MasterItemID,0) > 0
	BEGIN
		INSERT INTO [Transaction] (Date,FromQty, ToQty,ActionQty,Comment,IntegrationStatus,IntegrationReady, TrackingEntity_id,[User_id],[Type],[Process])
		SELECT getdate(),Qty,Qty,Qty,'Batch Change From:' + @Batch + '  to ->' + @NewBatch, 0,0,ID, @UserID,'BATCHCHANGE','BATCHCHANGE'
		FROM TrackingEntity WHERE MasterItem_id = @MasterItemID and Batch = @Batch
		UPDATE TrackingEntity SET Batch = @NewBatch 
		WHERE MasterItem_id = @MasterItemID and Batch = @Batch
	
		SELECT @message = 'Batch Update completed '
		SELECT @valid = 1
	END
END
ELSE
BEGIN
		SELECT @message = 'You did not confirm'
		SELECT @valid = 1
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
