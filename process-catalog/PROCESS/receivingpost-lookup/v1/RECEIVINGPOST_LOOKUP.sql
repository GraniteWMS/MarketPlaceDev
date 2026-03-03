INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','RECEIVINGPOST_LOOKUP','RECEIVINGPOST_LOOKUP','RECEIVINGPOST', '','True','True','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',0, 'True','True','',1,'RECEIVINGPOST_LOOKUP','','{{ "SELECT * FROM WebTemplate_PurchaseOrderPostLookup ORDER BY ExpectedDate" | dbSelect({}) | basicTable({selectOnColumn:"Number", enableSearch:true}) }}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm the Details to Post',1, 'True','True','',0,'RECEIVINGPOST_LOOKUP','','<div><small>Purchase Order:</small><header class="gn-float-right">{{Document}}</header></div>
{{"EXEC WebTemplate_PurchaseOrderPostDetail @value = @Document" |dbSelect({Document})|basicTable({})}}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Insert Confirm Label to Print in Receiving',200, 'True','True','',200,'RECEIVINGPOST_LOOKUP','PrescriptReceivingPostStep200','')