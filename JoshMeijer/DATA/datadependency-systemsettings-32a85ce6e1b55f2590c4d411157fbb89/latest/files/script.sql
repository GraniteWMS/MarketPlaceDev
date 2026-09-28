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
          'Granite.Function.StocktakeExport.Export'
        , 'Folder'
        , N'C:\Granite Installs\StocktakeExports'
        , N'Folder path for stocktake export CSV files'
        , 'string'
        , 0
        , 1
        , GETDATE()
        , N'0'
        , NULL
    )