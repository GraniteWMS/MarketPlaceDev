INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'ADJUST_TO_QTY', 'ADJUST QTY', 'CUSTOM', '', 'False', 'False', 'ab94d3e7-6044-5afb-ae52-d6f81b194626')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('TrackingEntity','TrackingEntity',0, 'True','True','',1,'ADJUST_TO_QTY','PrescriptAdjustToQtyTrackingEntity','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Qty','Qty',1, 'True','True','',0,'ADJUST_TO_QTY','PrescriptAdjustToQtyQty','')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Step200','Step200',200, 'True','True','',0,'ADJUST_TO_QTY','PrescriptAdjustToQtyStep200','')