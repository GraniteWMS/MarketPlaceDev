
CREATE PROCEDURE [dbo].[PrescriptCreatePickslipDocument]
    (
    @input dbo.ScriptInputParameters READONLY
)
AS
DECLARE @Output TABLE(
    Name varchar(max),
    Value varchar(max)  
  )
SET NOCOUNT ON;
DECLARE @valid bit = 1
DECLARE @message varchar(MAX)
DECLARE @stepInput varchar(50) = (SELECT Value FROM @input WHERE Name = 'StepInput')
DECLARE @user varchar(50) = (SELECT Value FROM @input WHERE Name = 'User')
DECLARE @Pickslip varchar(50) = (SELECT Value FROM @input WHERE Name = 'Pickslip')
DECLARE @ERPLocation varchar(30) = '1'
DECLARE @Site varchar(30) = ''
DECLARE @Document varchar(30) = TRIM(@stepInput)
DECLARE @DocumentType varchar(30) = 'PICKSLIP'
DECLARE @DocumentStatus varchar(30) = 'ENTERED'
DECLARE @PickslipID BIGINT
DECLARE @DocumentID BIGINT
DECLARE @StartNumber INT
DECLARE @TradingPartnerCode varchar(30) = ''
DECLARE @TradingPartnerDescription varchar(250) = ''
DECLARE @Description varchar(250) = 'PICK SLIP CREATED BY:' + @user
BEGIN TRY
	
	SELECT @DocumentID = ID FROM Document WHERE Number = @Document  AND Document.Type ='ORDER'		
	IF ISNULL(@DocumentID,0) = 0  
		RAISERROR('The scanned number %s is a not a valid and open Document',16,1,@Document)
	SELECT @PickslipID = ID FROM Document WHERE Number = @Pickslip
	IF ISNULL(@PickSlipID,0) = 0
		INSERT INTO Document (Number, TradingPartnerCode,TradingPartnerDescription, Description, ActionDate,CreateDate,isActive,Priority,ERPLocation,Site,AuditDate,AuditUser,Type,Status)
		SELECT @Pickslip,@TradingPartnerCode, @TradingPartnerDescription,@Description, getdate(), getdate(), 1, 1, @ERPLocation, @Site, getdate(), @User, @DocumentType, @DocumentStatus
	SELECT @PickslipID = ID FROM Document WHERE Number = @Pickslip
	SELECT @StartNumber = 1
IF (SELECT [Status] FROM Document WHERE ID = @DocumentID) NOT IN ('RELEASED','ENTERED') AND 
(SELECT COUNT(Qty) FROM DocumentDetail WHERE Document_id = @DocumentID) > (SELECT COUNT(ActionQty) FROM DocumentDetail WHERE Document_id = @DocumentID)
BEGIN
	UPDATE Document SET Status = 'RELEASED' WHERE ID = @DocumentID
	SELECT @message  = 'Document Status updated to Released'
END
SELECT @StartNumber = (SELECT MAX(isnull(CONVERT(INT, LineNumber),1))
FROM DocumentDetail WHERE Document_id = @PickslipID) + 10
IF isnull(@StartNumber,0) = 0
	SELECT @StartNumber = 1
	INSERT INTO DocumentDetail (LineNumber, Qty, UOM, UOMQty,ActionQty, UOMConversion, Completed, FromLocation, AuditDate, AuditUser, Item_id, Document_id, LinkedDetail_id, Comment) 
	SELECT @StartNumber + ROW_NUMBER() OVER(ORDER BY LineNumber ASC)  * 10 AS Line, Qty, DocumentDetail.UOM, UOMQty,ActionQty, UOMConversion, Completed, FromLocation, getdate(), @User, Item_id, @PickslipID, DocumentDetail.ID, @Document + ' ' + isnull(Comment,'') 
	FROM DocumentDetail INNER JOIN MasterItem ON DocumentDetail.Item_id = MasterItem.ID 
	WHERE Document_id = @DocumentID
	AND DocumentDetail.ID NOT IN (SELECT LinkedDetail_id FROM DocumentDetail WHERE Document_id = @PickslipID)
END TRY
BEGIN CATCH
	SELECT @valid = 0, @message = ERROR_MESSAGE()
END CATCH
INSERT INTO @Output
SELECT 'Message', @message
INSERT INTO @Output
SELECT 'Valid', @valid
INSERT INTO @Output
SELECT 'StepInput', @StepInput
SELECT *
FROM @Output
