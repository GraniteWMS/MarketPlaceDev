INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','OUTSTANDING_LOCATION_COUNT','OUTSTANDING_LOCATION_COUNT','STOCKTAKECOUNT', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Session','Session',0, 'True','False','',1,'OUTSTANDING_LOCATION_COUNT','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Count','Count',1, 'True','True','',2,'OUTSTANDING_LOCATION_COUNT','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Location','Location',2, 'True','True','',3,'OUTSTANDING_LOCATION_COUNT','','{{ "EXEC WebtemplateStockTakeLocation @Session = @Session, @Count = @Count" | dbSelect({Session, Count}) | basicTable({enableSearch:true}) }}')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',3, 'True','False','',4,'OUTSTANDING_LOCATION_COUNT','PrescriptStocktakeTrackingEntity','{{ "EXEC WebtemplateStockTakeTrackingEntity @Session = @Session, @Count = @Count, @Location = @Location" | dbSelect({Session, Count, Location}) | basicTable({enableSearch:false}) }}
')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('PalletConfirmation','PalletConfirmation',4, 'True','False','',5,'OUTSTANDING_LOCATION_COUNT','','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',5, 'True','False','',2,'OUTSTANDING_LOCATION_COUNT','','')