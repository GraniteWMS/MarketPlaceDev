INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','REINSTATE_TRACKINGENTITY','REINSTATE TRACKINGENTITY','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',1,'REINSTATE_TRACKINGENTITY','PrescriptReinstateTrackingEntityTrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Confirm', 'Confirm', 1, 'True', 'True', '', 0, 'REINSTATE_TRACKINGENTITY', '', 'df0cecb7-efdd-5f0d-a92b-2ad34ea4dd81')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',0,'REINSTATE_TRACKINGENTITY','PrescriptReinstateTrackingEntityStep200','')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('1','YES','REINSTATE_TRACKINGENTITY', 'Confirm')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('0','NO','REINSTATE_TRACKINGENTITY', 'Confirm')