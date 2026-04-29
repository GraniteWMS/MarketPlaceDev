INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PUTAWAY-DIRECTED','PUTAWAY-DIRECTED','MOVE', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('TrackingEntity', 'Scan Tracking Barcode', 0, 'True', 'True', '', 1, 'PUTAWAY-DIRECTED', '', '9c9f71cf-5274-5341-9bb9-79b87312ff2d')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Location', 'To Location', 1, 'True', 'True', '', 0, 'PUTAWAY-DIRECTED', '', '0fd8216a-51b2-548a-a9a8-b655417c2ffb')