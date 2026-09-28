
/* =========================================================
   SYSTEM SETTINGS INSERTS
   ========================================================= */

IF NOT EXISTS (
    SELECT 1
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Export'
      AND [Key] = 'Folder'
)
BEGIN
    ;
END



IF NOT EXISTS (
    SELECT 1
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'To'
)
BEGIN
    ;
END



IF NOT EXISTS (
    SELECT 1
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'Cc'
)
BEGIN
    ;
END



IF NOT EXISTS (
    SELECT 1
    FROM dbo.SystemSettings
    WHERE [Application] = 'Granite.Function.StocktakeExport.Email'
      AND [Key] = 'Bcc'
)
BEGIN
    ;
END

/* =========================================================
   EMAIL TEMPLATE
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.EmailTemplate
    WHERE [Name] = N'StocktakeExport'
)
BEGIN
    ;
END
