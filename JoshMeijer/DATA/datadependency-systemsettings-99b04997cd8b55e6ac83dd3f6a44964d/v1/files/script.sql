INSERT INTO dbo.SystemSettings
    (
          [Application]
        , [Key]
        , [Value]
        , [Description]
        , [ValueDataType]
        , [isEncrypted]
        , [isActive]
        , [AuditDate]
        , [AuditUser]
        , [EncryptionKey]
    )
    VALUES
    (
          'Granite.Function.StocktakeExport.Email'
        , 'To'
        , N'chriss@cradle.co.za;'
        , N'To email addresses for stocktake export'
        , 'string'
        , 0
        , 1
        , GETDATE()
        , N'0'
        , NULL
    )