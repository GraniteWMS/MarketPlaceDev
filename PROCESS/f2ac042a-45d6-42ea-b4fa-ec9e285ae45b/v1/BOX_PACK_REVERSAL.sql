-- =============================================
-- Process Template Deployment Script
-- Generated: 2025-10-10 10:08:12
-- Source: BOX_PACK_REVERSAL
-- =============================================

-- =============================================
-- DATA INSERTS
-- =============================================

-- ProcessStep_1
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('MasterItem','MasterItem',1, 'True','True','',2,'BOX_PACK_REVERSAL','','{{ "SELECT MasterItem, PackedQty FROM WebtemplateUnPackMasterItem WHERE Barcode = @Barcode " | dbSelect({Barcode}) | basicTable({selectOnColumn:"MasterItem", enableSearch:true}) }}')


-- ProcessStep_2
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Confirmation','Confirmation',2, 'True','True','',1,'BOX_PACK_REVERSAL','PrescriptUnpackBoxConfirmation','')


-- Process
INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','BOX_PACK_REVERSAL','BOX_PACK_REVERSAL','CUSTOM', '','False','False','')

-- ProcessStep_0
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Barcode','Box Barcode',0, 'True','True','',1,'BOX_PACK_REVERSAL','PrescriptUnpackBoxBarcode','')


-- =============================================
-- END OF SCRIPT
-- =============================================
