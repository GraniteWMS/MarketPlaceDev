INSERT INTO [Process] ([isActive], [Name], [Description], [Type], [IntegrationMethod], [IntegrationIsActive], [IntegrationPost], [WebTemplate])
VALUES('True', 'ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'CUSTOM', '', 'False', 'False', '1b184a49-25d5-5ab0-a589-68da9822b81d')
GO
INSERT INTO [ProcessStep] ([Name],[Description],[ProcessIndex],[isActive],[Required],[DefaultValue], [NextIndex],[Process],[PreScript],[WebTemplate]) 
VALUES('Type','Select Type',0, 'True','True','',1,'ASSIGN_PICKER_DETAIL_FROM_LISTBOX','','')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('Document', 'Document', 1, 'True', 'True', '', 2, 'ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'PrescriptAssignPickerDetailDocument', 'd98f4631-9ca0-5cd8-a509-5b8ac1213c13')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('AssignTo', 'Select User to Assign To', 2, 'True', 'True', '', 3, 'ASSIGN_PICKER_DETAIL_FROM_LISTBOX', '', '0e8ff74a-324b-534e-a3ae-39ee1c857879')
GO
INSERT INTO [ProcessStep] ([Name], [Description], [ProcessIndex], [isActive], [Required], [DefaultValue], [NextIndex], [Process], [PreScript], [WebTemplate])
VALUES('SelectedRecordID', 'Select Record(s) from Line List', 3, 'True', 'True', '', 3, 'ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'PrescriptAssignPickerDetailFromListSelectedRecordID', 'b234e953-5f2b-5743-857f-99e7d7c98484')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('ASSIGN','Assign','ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'Type')
GO
INSERT INTO [ProcessStepLookup] ([Value],[Description],[Process],[ProcessStep]) 
VALUES('UNASSIGN','Unassign','ASSIGN_PICKER_DETAIL_FROM_LISTBOX', 'Type')