-- =============================================
-- Email Template Data Upsert
-- =============================================
SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM [EmailTemplate] WHERE [Name] = N'IntegrationError')
BEGIN
    UPDATE [EmailTemplate]
    SET [Description] = N'This template is used by Scheduler injected jobs to notify of a failed document sync',
        [Definition] = N'{{
  headerImage({
    imageUrl:''https://www.granitewms.com/wp-content/uploads/2020/07/GraniteWMS-1.png'',
    backgroundColor:''#182026''
  })
}}

# Document {{documentNumber}} failed to sync

{{#if documentLogs}}
### Document header failed to sync:
{{documentLogs}}
{{/if}}

{{#if documentDetailLogs}}
### Document details failed to sync:
{{documentDetailLogs}}
{{/if}}',
        [Format] = N'markdown',
        [AuditDate] = GETDATE(),
        [AuditUser] = N'AUTOMATION',
        [Version] = 1
    WHERE [Name] = N'IntegrationError';
END
ELSE
BEGIN
    INSERT INTO [EmailTemplate] ([Name], [Description], [Definition], [Format], [AuditDate], [AuditUser], [Version])
    VALUES (N'IntegrationError', N'This template is used by Scheduler injected jobs to notify of a failed document sync', N'{{
  headerImage({
    imageUrl:''https://www.granitewms.com/wp-content/uploads/2020/07/GraniteWMS-1.png'',
    backgroundColor:''#182026''
  })
}}

# Document {{documentNumber}} failed to sync

{{#if documentLogs}}
### Document header failed to sync:
{{documentLogs}}
{{/if}}

{{#if documentDetailLogs}}
### Document details failed to sync:
{{documentDetailLogs}}
{{/if}}', N'markdown', GETDATE(), N'AUTOMATION', 1);
END

