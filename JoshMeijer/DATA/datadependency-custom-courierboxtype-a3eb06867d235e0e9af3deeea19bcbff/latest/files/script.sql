INSERT INTO dbo.Custom_CourierBoxType
        (
            Code, Description, [Length], [Width], [Height], DimensionUOM,
            MaxWeight, WeightUOM, IsActive, AuditDate, AuditUser, [Version]
        )
        VALUES
        (
            'BOX_LARGE', 'Large box', 50.000000, 40.000000, 35.000000, 'CM',
            150.000000, 'KG', 1, GETDATE(), 'SYSTEM', 1
        )