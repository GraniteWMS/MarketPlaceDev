INSERT INTO dbo.Custom_CourierBoxType
        (
            Code, Description, [Length], [Width], [Height], DimensionUOM,
            MaxWeight, WeightUOM, IsActive, AuditDate, AuditUser, [Version]
        )
        VALUES
        (
            'BOX_XL', 'Extra large box', 60.000000, 45.000000, 45.000000, 'CM',
            200.000000, 'KG', 1, GETDATE(), 'SYSTEM', 1
        )