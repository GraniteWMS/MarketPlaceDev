CREATE PROCEDURE [dbo].[PrescriptPickingTrackingEntity] (
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
DECLARE @Qty varchar(30)
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
SELECT @Qty = Qty FROM TrackingEntity WHERE Barcode = @StepInput
INSERT INTO @Output
SELECT 'Qty', @Qty
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
