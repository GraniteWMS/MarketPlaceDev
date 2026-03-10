INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','STOCKTAKE_ADD_LOCATION','STOCKTAKE_ADD_LOCATION','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Session', 'Stocktake Session', 0, 'True', 'True', '', 1, 'STOCKTAKE_ADD_LOCATION', 'PrescriptAddLocationsToStockTake', 'c6482f19-b419-52dd-bbb9-c71ddc5d7c53')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',1, 'True','True','',2,'STOCKTAKE_ADD_LOCATION','PrescriptAddLocationsToStockTakeLocation','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirm',2, 'True','True','',1,'STOCKTAKE_ADD_LOCATION','PrescriptAddLocationsToStockTakeConfirmation','')