INSERT INTO dbo.Custom_CourierBoxType
        (
            Code, Description, [Length], [Width], [Height], DimensionUOM,
            MaxWeight, WeightUOM, IsActive, AuditDate, AuditUser, [Version]
        )
        VALUES
        (
            'BOX_MEDIUM', 'Medium box', 40.000000, 30.000000, 25.000000, 'CM',
            100.000000, 'KG', 1, GETDATE(), 'SYSTEM', 1
        )