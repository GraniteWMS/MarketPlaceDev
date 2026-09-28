CREATE PROCEDURE [dbo].[Prescript_Picking_Qty] (
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
DECLARE @Document varchar(50) = (SELECT Value FROM @input WHERE Name = 'Document')
DECLARE @TrackingEntityBarcode varchar (50) = (SELECT Value FROM @input WHERE Name = 'TrackingEntity') 
DECLARE @MasterItem_id bigint
DECLARE @LPReset bit = 0		
BEGIN TRY
	SELECT @MasterItem_id = MasterItem_id FROM TrackingEntity WHERE Barcode = @TrackingEntityBarcode
	SELECT @valid = 1
END TRY
BEGIN CATCH
	SELECT @valid = 0,
	@message = ERROR_MESSAGE()  
END CATCH
 
INSERT INTO @Output (Name, Value)
VALUES
    ('Message',  @message),
    ('Valid',    CONVERT(varchar(10), @valid)),
    ('StepInput',@stepInput);
SELECT * FROM @Output
