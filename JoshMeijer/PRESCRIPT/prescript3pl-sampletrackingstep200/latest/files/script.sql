CREATE PROCEDURE [dbo].[Prescript3PL_SampleTrackingStep200] (
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
DECLARE @TrackingEntityBarcode varchar(50)
DECLARE @SampleQty decimal(19,4)
DECLARE @DocumentReference varchar(50)
DECLARE @Coment varchar(100)
DECLARE @UserName varchar(30)
DECLARE @userID bigint
DECLARE @Comment varchar(max)
DECLARE @Sampler varchar(50)
SELECT @Sampler = [Value] FROM @input WHERE [Name] = 'Sampler'
SELECT @DocumentReference = [Value] FROM @input WHERE [Name] = 'DocumentReference'
SELECT @TrackingEntityBarcode = [Value] FROM @input WHERE [Name] = 'TrackingEntity'
SELECT @SampleQty = [Value] FROM @input WHERE [Name] = 'Qty'
SELECT @Comment = [Value] FROM @input WHERE [Name] = 'Comment'
SELECT @UserName = [Value] FROM @input WHERE [Name] = 'User'
SELECT @userID = ID FROM Users WHERE Name = @UserName
INSERT INTO [Transaction] (Date,FromQty,ToQty, ActionQty, DocumentReference, Comment, IntegrationStatus, IntegrationReady,
TrackingEntity_id, User_id, FromLocation_id, [Type], [Process])
SELECT getdate(), Qty, Qty, @SampleQty, @DocumentReference, CONCAT(@Sampler,':',@Comment), 0,0,
ID,@UserID, Location_id, 'SAMPLE','3PL_SAMPLETRACKINGENTITY'
FROM TrackingEntity 
WHERE Barcode = @TrackingEntityBarcode
SELECT @valid = 1
SELECT @message = CONCAT('Sample Transaction Logged for Tracking Barcode: ', @TrackingEntityBarcode ) 
	INSERT INTO @Output
	SELECT 'Message', @message
	INSERT INTO @Output
	SELECT 'Valid', @valid
	INSERT INTO @Output
	SELECT 'StepInput', @stepInput
	SELECT * FROM @Output
