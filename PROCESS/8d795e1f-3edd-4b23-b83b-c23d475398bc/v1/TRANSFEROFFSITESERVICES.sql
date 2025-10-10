-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: TRANSFEROFFSITESERVICES
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Comment','Document/Reference',1, 'True','True','',2,'TRANSFEROFFSITESERVICES','','')


-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty to Replenish',3, 'True','True','',4,'TRANSFEROFFSITESERVICES','','')


-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Reference','Reference',100, 'True','True','',100,'TRANSFEROFFSITESERVICES','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',4, 'True','True','',2,'TRANSFEROFFSITESERVICES','','<div><small>Document/Reference:</small><header class="gn-float-right">{{Comment}}</header></div>
<div><small>Transactions already processed for this Reference:</small></div>
{{"EXEC WebTemplate_TransferOffsiteConfirmation @Comment= @Comment" |dbSelect({Comment})|basicTable({})}}')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('FromTrackingEntity','FromTrackingEntity',2, 'True','True','',3,'TRANSFEROFFSITESERVICES','','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','TRANSFEROFFSITESERVICES','Transfer to Offsite Services','REPLENISH', '','True','True','')

-- ProcessStep_100
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('ToTrackingEntity','To TrackingEntity',100, 'True','False','',100,'TRANSFEROFFSITESERVICES','','')


-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Select which site',0, 'True','True','',1,'TRANSFEROFFSITESERVICES','PrescriptTransferOffsiteLocation','{{ "SELECT Barcode FROM WebTemplate_OffsiteServicesLocations" | dbSelect({}) | basicTable({selectOnColumn:"Barcode", enableSearch:false}) }}')


-- =============================================
-- END OF SCRIPT
-- =============================================
