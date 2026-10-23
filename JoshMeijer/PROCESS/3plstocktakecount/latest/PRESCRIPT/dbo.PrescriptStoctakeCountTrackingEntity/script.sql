CREATE PROCEDURE [dbo].[PrescriptStoctakeCountTrackingEntity] (
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
DECLARE @user varchar(30) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @stepInput varchar(MAX) = (SELECT Value FROM @input WHERE Name = 'StepInput') 
DECLARE @Location varchar(30)
DECLARE @Batch varchar(50)
DECLARE @Qty varchar(20)
SELECT @Batch = TE.Batch, @Location = L.Barcode, @Qty = TE.Qty
FROM TrackingEntity TE INNER JOIN 
Location L ON TE.Location_id = L.ID
WHERE TE.Barcode = @stepInput
INSERT INTO @Output
SELECT 'Batch', @Batch
INSERT INTO @Output
SELECT 'Location', @Location
INSERT INTO @Output
SELECT 'Qty', @Qty
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
