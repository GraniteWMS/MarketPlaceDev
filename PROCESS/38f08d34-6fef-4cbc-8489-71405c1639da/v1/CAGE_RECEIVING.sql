-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 07:32:33
-- Source: CAGE_RECEIVING
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_3
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',3, 'True','True','',4,'CAGE_RECEIVING','','')


-- ProcessStep_4
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('NoEntities','Number of TrackingEntities',4, 'True','False','',2,'CAGE_RECEIVING','','')


-- ProcessStep_99
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Print','Print',99, 'True','True','',0,'CAGE_RECEIVING','','')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',2, 'True','True','',3,'CAGE_RECEIVING','','{{ "SELECT Code, Description, Completion FROM WebTemplate_CageReceiving_MasterItem WHERE Document = @Document" | dbSelect({Document}) | basicTable({selectOnColumn:"Code", enableSearch:true}) }}')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','CAGE_RECEIVING','CAGE RECEIVING','RECEIVING', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Receiving Location',0, 'True','False','',1,'CAGE_RECEIVING','','')


-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Document','Document',1, 'True','True','',2,'CAGE_RECEIVING','','{{ "SELECT Document, Supplier FROM WebTemplate_CageReceiving_Document WHERE Cage = @Location" | dbSelect({Location}) | basicTable({selectOnColumn:"Document", enableSearch:true}) }}')


-- =============================================
-- END OF SCRIPT
-- =============================================
