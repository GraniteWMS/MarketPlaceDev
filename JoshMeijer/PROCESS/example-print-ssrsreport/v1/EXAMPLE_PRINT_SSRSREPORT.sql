INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_PRINT_SSRSREPORT','EXAMPLE_PRINT_SSRSREPORT','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_PRINT_SSRSREPORT','Prescript_Example_PrintSsrsReport','')