
CREATE PROCEDURE [dbo].[PrescriptPackCarryingEntity] (
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

DECLARE @sql varchar(max)
DECLARE @OrderBy varchar(max)
DECLARE @html varchar(max) = ''

DECLARE @carryingEntity varchar(50) = @StepInput 
DECLARE @CarryingEntity_id BIGINT

IF SUBSTRING(@carryingEntity,1,7) = 'SHIPPER' or isnull(@CarryingEntity,'') = '' or UPPER(@carryingEntity) = 'NEW' 
BEGIN
	IF EXISTS(SELECT * FROM CarryingEntity WHERE Barcode = @carryingEntity)
	BEGIN
		SELECT @CarryingEntity_id  = ID FROM CarryingEntity WHERE Barcode = @carryingEntity
		IF isnull(@CarryingEntity_id,0) > 0
		BEGIN
	
			SELECT @sql = CONCAT('SELECT Code, Description,Qty,
			''LightGrey'' as RowColor 
									FROM TrackingEntity  INNER JOIN MasterItem ON TrackingEntity.MasterItem_id = MasterItem.ID
									WHERE BelongsToEntity_id = ', @carryingEntity_id, '')

			SELECT @OrderBy = 'ORDER BY Code ASC'

			EXEC dbo.SqlToHtml @sql, @OrderBy, @html OUTPUT


		END
		SELECT @valid = 1
		SELECT @message = ''

	END
	ELSE 
		SELECT @html = ''
END
ELSE
BEGIN
	SELECT @valid = 0
	SELECT @message = 'Invalid Pallet Barcode'
	SELECT @html = ''

END


INSERT INTO @Output
SELECT 'Instruction', @html

INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @stepInput

SELECT * FROM @Output

