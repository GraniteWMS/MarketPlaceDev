IF NOT EXISTS (SELECT 1 FROM [dbo].[Type] WHERE [Name] = N'UNPACK' AND [AppliesTo] = N'TRANSACTION') 
BEGIN 
	INSERT INTO [dbo].[Type] ([Name], [Description], [isActive], [AppliesTo], [Locked]) 
	VALUES (N'UNPACK', NULL, 1, N'TRANSACTION', 1) 
END