INSERT INTO dbo.Custom_CourierBoxType
        (
            Code, Description, [Length], [Width], [Height], DimensionUOM,
            MaxWeight, WeightUOM, IsActive, AuditDate, AuditUser, [Version]
        )
        VALUES
        (
            'BOX_XS', 'Extra small box', 20.000000, 15.000000, 10.000000, 'CM',
            20.000000, 'KG', 1, GETDATE(), 'SYSTEM', 1
        )