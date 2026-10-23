CREATE PROCEDURE [dbo].[Prescript_ReceiveIngredients_Step200] (
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
DECLARE @UserID bigint
DECLARE @User varchar(MAX) 
DECLARE @MasterItem varchar(200) = (SELECT Value FROM @input WHERE Name = 'MasterItem')
SELECT @User = Value FROM @input WHERE Name = 'User' 
SELECT @UserID = ID FROM [Users] WHERE Name = @User
DECLARE @Document varchar(50)
SELECT @Document = Value FROM @input WHERE Name = 'OptionalFieldValue0'
DECLARE @Supplier varchar(50)
SELECT @Supplier = Value FROM @input WHERE Name = 'OptionalFieldValue1'
If isnull(@Supplier,'') = ''
	SELECT @Supplier = CATEGORY FROM [dbo].[MasterItem]
	WHERE Code = @MasterItem
DECLARE @temptable TABLE
(
	TrackingEntityID BIGINT
) 
INSERT INTO @temptable (TrackingEntityID)
SELECT TrackingEntity_id FROM [Transaction]
WHERE User_id = @UserID and DATEDIFF(SECOND,[Date],GETDATE()) < 30 AND [Process] = 'RECEIVE_INGREDIENTS'
DECLARE @DocumentOptField_id bigint = (SELECT ID FROM OptionalFields WHERE [Name] = 'Document' and AppliesTo = 'TRACKINGENTITY' and isActive  =1)
DECLARE @SupplierOptField_id bigint = (SELECT ID FROM OptionalFields WHERE [Name] = 'Supplier' and AppliesTo = 'TRACKINGENTITY' and isActive  =1)
INSERT INTO OptionalFieldValues_TrackingEntity (Value,OptionalField_id,BelongsTo_id)
SELECT @Document,@DocumentOptField_id,TrackingEntityID
FROM @temptable
INSERT INTO OptionalFieldValues_TrackingEntity (Value,OptionalField_id,BelongsTo_id)
SELECT @Supplier,@SupplierOptField_id,TrackingEntityID
FROM @temptable
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
