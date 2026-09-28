
CREATE PROCEDURE [dbo].[Utility_CopyDocument]
	@Document varchar(50),
	@NewDocument varchar(50), 
	@NewStatus varchar(30),
	@NewType varchar(30)
AS
BEGIN
DECLARE @DocumentID bigint
SELECT @DocumentID = ID FROM Document WHERE Number = @Document
DECLARE @NewDocumentID bigint
SELECT @NewDocumentID = ID FROM Document WHERE Number = @NewDocument
IF		ISNULL(@DocumentID,0) > 0		
	AND ISNULL(@NewDocumentID,0) = 0	
BEGIN	
	INSERT INTO [dbo].[Document]
           ([Number],[TradingPartnerCode],[TradingPartnerDescription],[Description],[ActionDate],[CreateDate],[ExpectedDate]
           ,[isActive] ,[Priority],[ERPLocation],[Site],[AuditDate] ,[AuditUser] ,[Type] ,[Status],Version)
	SELECT		@NewDocument
           ,[TradingPartnerCode]
           ,[TradingPartnerDescription]
           ,[Description]
           ,[ActionDate]
           ,[CreateDate]
           ,[ExpectedDate]
           ,[isActive]
           ,[Priority]
           ,[ERPLocation]
           ,[Site]
           ,getdate()
           ,'AUTOMATION'
           ,@NewType
           ,@NewStatus
		   ,Version
	FROM Document WHERE ID = @DocumentID
	SELECT @NewDocumentID  = ID FROM Document WHERE Number = @NewDocument
END		
INSERT INTO [dbo].[DocumentDetail]
           ([LineNumber]
           ,[UOMQty]
           ,[Qty]
           ,[UOM]
           ,[UOMConversion]
           ,[Completed]
           ,[UnitValue]
           ,[Comment]
           ,[MultipleEntries]
           ,[FromLocation]
           ,[ToLocation]
           ,[IntransitLocation]
           ,[Batch]
           ,[ExpiryDate]
           ,[SerialNumber]
           ,[AuditDate]
           ,[AuditUser]
           ,[Item_id]
           ,[Document_id]
           ,[Status]
           ,[Type]
           ,[Cancelled]
		   ,[Version]
)
SELECT      [LineNumber]
           ,[UOMQty]
           ,[Qty]
           ,[UOM]
           ,[UOMConversion]
           ,[Completed]
           ,[UnitValue]
           ,[Comment]
           ,[MultipleEntries]
           ,isnull([FromLocation],'A2')
           ,isnull([ToLocation],'A2')
           ,[IntransitLocation]
           ,[Batch]
           ,[ExpiryDate]
           ,[SerialNumber]
           ,[AuditDate]
           ,[AuditUser]
           ,[Item_id]
           ,@NewDocumentID
           ,[Status]
           ,[Type]
           ,[Cancelled]
		   ,[Version]
FROM DocumentDetail WHERE Document_id = @DocumentID
AND NOT EXISTS (SELECT ID FROM DocumentDetail DD WHERE Document_id = @NewDocumentID AND DD.LineNumber = DocumentDetail.LineNumber)
END
