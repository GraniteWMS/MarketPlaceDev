INSERT INTO [Process] ([isActive],[Name],[Description],[Type],[IntegrationMethod],[IntegrationIsActive],[IntegrationPost],[WebTemplate]) 
VALUES('True','RECEIVINGPOST_LOOKUP','RECEIVINGPOST_LOOKUP','RECEIVINGPOST', '','True','True','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Document', 'Document', 0, 'True', 'True', '', 1, 'RECEIVINGPOST_LOOKUP', '', 'd6b43eab-6208-543f-b954-b3447e5a376b')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Confirmation', 'Confirm the Details to Post', 1, 'True', 'True', '', 0, 'RECEIVINGPOST_LOOKUP', '', 'd5f5871d-55d0-5321-97cb-3c4a2ec6d5d5')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Insert Confirm Label to Print in Receiving',200, 'True','True','',200,'RECEIVINGPOST_LOOKUP','PrescriptReceivingPostStep200','')