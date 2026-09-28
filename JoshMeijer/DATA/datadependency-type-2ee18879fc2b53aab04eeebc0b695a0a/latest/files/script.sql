INSERT INTO [dbo].[Type]
           ([Name],[Description],[isActive] ,[AppliesTo],[Locked],[AuditDate] ,[AuditUser],[Version])
     VALUES
           ('PICKSTAGING','PICKSTAGING',1,'LOCATION',0,getdate(),'AUTOMATION',1)