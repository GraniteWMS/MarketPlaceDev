INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','EXAMPLE_EXPORT_TABLETOEXCEL','EXAMPLE_EXPORT_TABLETOEXCEL','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Example','Example',0, 'True','True','',0,'EXAMPLE_EXPORT_TABLETOEXCEL','Prescript_Example_ExportExcelFile','')