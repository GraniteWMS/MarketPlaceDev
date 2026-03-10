INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','BOX_PACK_REVERSAL','BOX_PACK_REVERSAL','CUSTOM', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Barcode','Box Barcode',0, 'True','True','',1,'BOX_PACK_REVERSAL','PrescriptUnpackBoxBarcode','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('MasterItem', 'MasterItem', 1, 'True', 'True', '', 2, 'BOX_PACK_REVERSAL', '', '2e4fbf1f-4826-5a46-982b-fd0af7e292a2')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',2, 'True','True','',1,'BOX_PACK_REVERSAL','PrescriptUnpackBoxConfirmation','')