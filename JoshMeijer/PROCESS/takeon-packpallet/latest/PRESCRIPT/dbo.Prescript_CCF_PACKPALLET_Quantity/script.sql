
CREATE PROCEDURE [dbo].[Prescript_CCF_PACKPALLET_Quantity] (
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
DECLARE @site varchar(10) = 'CCF'
SELECT @stepInput = Value FROM @input WHERE Name = 'StepInput' 
DECLARE @PalletBarcode varchar(50) = (SELECT Value FROM @input WHERE Name = 'PalletBarcode')
DECLARE @PalletQty int = 60
DECLARE @QtyLeft int
BEGIN TRY
	IF ISNUMERIC(@stepInput) = 0
		RAISERROR('The pallet Qty must be a number',16,1)
	IF TRY_CONVERT(int,@stepInput) > @PalletQty
		RAISERROR('The pallet Qty must be less than or equal to 60',16,1)
	SELECT @QtyLeft = @PalletQty - SUM(Qty) FROM TrackingEntity 
											WHERE BelongsToEntity_id = (SELECT ID FROM CarryingEntity 
																		WHERE Barcode = @PalletBarcode)
	IF @QtyLeft = 0
		RAISERROR('Pallet already has 60 cases -you cannot add to it',16,1)
	IF @QtyLeft < Try_Convert(int,@stepInput)
		RAISERROR('The pallet can only have 60 cases.  It can only have %d more.  You cannot go above 60',16,1,@QtyLeft)
	SELECT @valid = 1
	SELECT @message = ''
END TRY
BEGIN CATCH
		SELECT @valid = 0
		SELECT @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput
SELECT * FROM @Output
