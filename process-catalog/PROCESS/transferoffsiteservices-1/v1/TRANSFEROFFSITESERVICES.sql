INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','TRANSFEROFFSITESERVICES','Transfer to Offsite Services','REPLENISH', '','True','True','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Select which site',0, 'True','True','',1,'TRANSFEROFFSITESERVICES','PrescriptTransferOffsiteLocation','{{ "SELECT Barcode FROM WebTemplate_OffsiteServicesLocations" | dbSelect({}) | basicTable({selectOnColumn:"Barcode", enableSearch:false}) }}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Document/Reference',1, 'True','True','',2,'TRANSFEROFFSITESERVICES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ToTrackingEntity','To TrackingEntity',100, 'True','False','',100,'TRANSFEROFFSITESERVICES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',100, 'True','True','',100,'TRANSFEROFFSITESERVICES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromTrackingEntity','FromTrackingEntity',2, 'True','True','',3,'TRANSFEROFFSITESERVICES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty to Replenish',3, 'True','True','',4,'TRANSFEROFFSITESERVICES','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',4, 'True','True','',2,'TRANSFEROFFSITESERVICES','','<div><small>Document/Reference:</small><header class="gn-float-right">{{Comment}}</header></div>
<div><small>Transactions already processed for this Reference:</small></div>
{{"EXEC WebTemplate_TransferOffsiteConfirmation @Comment= @Comment" |dbSelect({Comment})|basicTable({})}}')