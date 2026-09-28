CREATE PROCEDURE [dbo].[PrescriptLoadTruckStep200] (
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
DECLARE @User varchar(50)
DECLARE @TrackingEntity varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @TrackingEntity=  Value FROM @input WHERE Name = 'TrackingEntity'
UPDATE TrackingEntity SET InStock = 0 WHERE Barcode = @TrackingEntity
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
