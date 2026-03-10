-- =============================================
-- Process Data Inserts
-- =============================================

-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate])
VALUES('True','CUSTOM','CUSTOM','CUSTOM','','False','False',NULL)

-- ProcessSteps
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Custom1','Custom1',0,'True','True','',1,'CUSTOM','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Custom2','Custom2',1,'True','True','',0,'CUSTOM','',NULL)

INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue],[NextIndex],[Process],[PreScript],[WebTemplate])
VALUES('Step200','Step200',200,'True','True','',0,'CUSTOM','Prescript_Custom_Step200',NULL)

