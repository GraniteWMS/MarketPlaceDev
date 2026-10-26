CREATE   PROCEDURE [dbo].[Utility_WriteAudit]
    @TableName    VARCHAR(35),
    @Entries      dbo.Utility_AuditEntry READONLY,
    @ChangeType   VARCHAR(10) = 'UPDATE',   
    @Application  VARCHAR(50) = NULL,       
    @User         VARCHAR(20) = 'AUTOMATION',
    @RowsWritten  INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    INSERT INTO Audit (
        AuditDate, AuditTime, [User], RecordID, Application,
        TableName, ChangeType, ColumnName, PreviousValue, NewValue, RecordVersion
    )
    SELECT
        CAST(@Now AS DATE), CAST(@Now AS TIME(7)), @User, e.RecordID, @Application,
        @TableName, @ChangeType, e.ColumnName, e.PreviousValue, e.NewValue, e.RecordVersion
    FROM @Entries e
    WHERE NOT (
        @ChangeType = 'UPDATE'
        AND (   (e.PreviousValue IS NULL AND e.NewValue IS NULL)
             OR  e.PreviousValue = e.NewValue)   
    );
    SET @RowsWritten = @@ROWCOUNT;
END
