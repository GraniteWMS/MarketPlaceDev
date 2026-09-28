CREATE PROCEDURE [dbo].[Prescript3PL_LOADOUTDOC_Step200] (
   @input dbo.ScriptInputParameters READONLY 
)
AS
DECLARE @Output TABLE(
  Name varchar(max),  
  Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX) = 'TEST'
DECLARE @stepInput varchar(MAX)  = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @user varchar(50) =(SELECT Value FROM @input WHERE Name = 'User')
DECLARE @user_id bigint
DECLARE @Principle varchar(50) = (SELECT Value FROM @input WHERE Name = 'Principle')
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @Document_id bigint
DECLARE @ExpectedDate varchar(30) = (SELECT Value FROM @input WHERE Name = 'ExpectedDate')
DECLARE @Priority int
DECLARE @TradingPartnerCode varchar(30) = @Principle
DECLARE @TradingPartnerDescription varchar(250) = (SELECT Description FROM TradingPartner WHERE Code = @Principle)
DECLARE @ERPLocation varchar(15) = (SELECT Value FROM @input WHERE Name = 'FromLocation')
DECLARE @Site varchar(30) = (SELECT Site FROM Users WHERE Name = @user)
DECLARE @MasterItemCode varchar(50)  =(SELECT Value FROM @input WHERE Name = 'MasterItem')
DECLARE @MasterItem_id bigint
DECLARE @Batch varchar(50) = (SELECT Value FROM @input WHERE Name = 'Batch')
DECLARE @DocumentLine_id bigint
DECLARE @Qty varchar(20) =(SELECT Value FROM @input WHERE Name = 'Qty')
DECLARE @LineNumber varchar(10) = '0'
DECLARE @Comment varchar(250) = (SELECT Value FROM @input WHERe Name = 'Comment')
DECLARE @UOM varchar(20)
SELECT @user_id = ID FROM Users WHERE Name = @User 
SELECT @Document_id = ID FROM Document WHERE Number = @Document
SELECT @MasterItem_id = ID, @UOM = UOM FROM MasterItem WHERE Code = @MasterItemCode
SELECT @message = @stepInput
SELECT @valid = 1
IF isnull(@Document_id,0) = 0
BEGIN
	INSERT INTO Document (Number, Type, Status, TradingPartnerCode, TradingPartnerDescription, Description,CreateDate,
	ExpectedDate,isActive,Priority,ERPLocation, Site,AuditDate,AuditUser, Version, Principle)
	SELECT @Document, 'ORDER','ENTERED', @TradingPartnerCode, @TradingPartnerDescription, '',getdate(), 
	NULL,1,CONVERT(int,@Priority), @ERPLocation,@Site,getdate(), @User, 1, @Principle
	
	UPDATE BarcodeMaster SET NextBarcode = NextBarcode + 1 WHERE Name = 'DocumentOrder'
	
	SELECT @Document_id = ID FROM Document WHERE Number = @Document
	SELECT @message = 'Document Created'
END
ELSE  
BEGIN
	SELECT @message = 'Document Exists'
END
SELECT @DocumentLine_id  = ID FROM DocumentDetail WHERE Document_id = @Document_id and Item_id = @MasterItem_id AND Batch = @Batch
IF isnull(@DocumentLine_id,0) = 0  
BEGIN
	
	SELECT TOP 1 @LineNumber = LineNumber FROM DocumentDetail WHERE Document_id = @Document_id ORDER BY ID DESC
	IF isnull(@LineNumber,'0') = '0' 
		SELECT @LineNumber = '10'
	ELSE 
		SELECT @LineNumber = CONVERT(varchar(10),CONVERT(int,@LineNumber) + 10)
		
	INSERT INTO DocumentDetail (Document_id,Item_id,LineNumber,Qty,ActionQty,UOM,Comment,Batch, FromLocation, Completed,
	 Cancelled, AuditDate, AuditUser, Version)
	SELECT @Document_id, @MasterItem_id, @LineNumber, @Qty, 0, @UOM, @Comment, @Batch, @ERPLocation, 0,
	0,GETDATE(), @user, 1
	SELECT @message = 'Added Document Line'
	SELECT @valid = 1
END
ELSE
BEGIN
	UPDATE DocumentDetail SET Qty = @Qty, AuditDate = getdate(), AuditUser = @user, Version = Version +1
	WHERE ID = @DocumentLine_id
	SELECT @message = 'Document Exists - Line exists -Updating Qty'
	SELECT @valid = 1
END
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
