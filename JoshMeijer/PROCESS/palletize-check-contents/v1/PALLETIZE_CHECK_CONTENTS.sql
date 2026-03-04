INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','PALLETIZE_CHECK_CONTENTS','PALLETIZE ADD','PALLETIZE', '','False','False','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('CarryingEntity','CarryingEntity (Pallet)',0, 'True','False','',1,'PALLETIZE_CHECK_CONTENTS','','<style> #btnNew { display:none } </style>')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',1, 'True','False','',1,'PALLETIZE_CHECK_CONTENTS','PrescriptPalletizeCheckContentsTrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Type',100, 'True','False','Add',1,'PALLETIZE_CHECK_CONTENTS','','')