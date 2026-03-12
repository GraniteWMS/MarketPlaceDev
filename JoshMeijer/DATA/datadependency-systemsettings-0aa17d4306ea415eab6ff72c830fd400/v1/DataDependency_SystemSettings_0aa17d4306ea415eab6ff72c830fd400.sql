-- =============================================
-- Data Dependency Inserts
-- =============================================
-- dbo.SystemSettings

SET IDENTITY_INSERT [dbo].[SystemSettings] ON;
INSERT INTO [dbo].[SystemSettings] ([ID], [Application], [Key], [Value], [Description], [ValueDataType], [isActive], [isEncrypted], [EncryptionKey], [AuditDate], [AuditUser], [Version], [GUID]) VALUES (5, N'Granite.Custodian', N'Token', N'qlL0OC2DjetOxQWFfaVHomADvFcjHqJsmRwCDly5SjA8rwj6tNxEN4KqwWlma3tGpDP3TZHkzUH+AzcYGdxMs4MQoZ8nGsuqewxijDVbTp79II816l4bEFfsLVHvWp7Rr3MEEo4U7n1MDCCwqbPdFjo9ixo2A5SFMUZD1/+UGcd2DuFcegJ5+9nJYV2za0Own7ZsfuPL4WipDjS/2oBhkU7w36HBOVNOuaG/O6bMQo6Uya2C3lGX5VPalYsd8Uqw', N'', N'string', 1, 1, N'3SsPIaHkYgQdiMhgeRsMpA==', '2026-01-20 13:54:40.537', N'MANUAL', 6, '7a49150b-0005-4c07-917b-50a2db7afce9');
SET IDENTITY_INSERT [dbo].[SystemSettings] OFF;
