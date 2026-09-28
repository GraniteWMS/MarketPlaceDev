CREATE   PROCEDURE dbo.Custom_DeliveryNoteLoadingBay_Set
    @Action         VARCHAR(10),   
    @DocumentID     BIGINT,
    @LoadingBay     VARCHAR(50) = NULL,
    @UserName       VARCHAR(100),
    @Comments       VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OldLoadingBay VARCHAR(50);
    SELECT @OldLoadingBay = LoadingBay
    FROM dbo.DeliveryNoteLoadingBay
    WHERE Document_id = @DocumentID;
    IF @Action = 'ASSIGN'
    BEGIN
        IF ISNULL(@LoadingBay, '') = ''
        BEGIN
            RAISERROR('LoadingBay is required when Action = ASSIGN', 16, 1);
            RETURN;
        END
        IF @OldLoadingBay IS NULL
        BEGIN
            INSERT INTO dbo.DeliveryNoteLoadingBay
            (
                Document_id,
                LoadingBay,
                AssignedDate,
                AssignedBy,
                Comments
            )
            VALUES
            (
                @DocumentID,
                @LoadingBay,
                GETDATE(),
                @UserName,
                @Comments
            );
            INSERT INTO dbo.DeliveryNoteLoadingBayAudit
            (
                Document_id,
                OldLoadingBay,
                NewLoadingBay,
                AuditAction,
                AuditDate,
                AuditBy,
                Comments
            )
            VALUES
            (
                @DocumentID,
                NULL,
                @LoadingBay,
                'ASSIGN',
                GETDATE(),
                @UserName,
                @Comments
            );
        END
        ELSE IF @OldLoadingBay <> @LoadingBay
        BEGIN
            UPDATE dbo.DeliveryNoteLoadingBay
            SET LoadingBay = @LoadingBay,
                AssignedDate = GETDATE(),
                AssignedBy = @UserName,
                Comments = @Comments
            WHERE Document_id = @DocumentID;
            INSERT INTO dbo.DeliveryNoteLoadingBayAudit
            (
                Document_id,
                OldLoadingBay,
                NewLoadingBay,
                AuditAction,
                AuditDate,
                AuditBy,
                Comments
            )
            VALUES
            (
                @DocumentID,
                @OldLoadingBay,
                @LoadingBay,
                'MOVE',
                GETDATE(),
                @UserName,
                @Comments
            );
        END
    END
    ELSE IF @Action = 'REMOVE'
    BEGIN
        IF @OldLoadingBay IS NOT NULL
        BEGIN
            INSERT INTO dbo.DeliveryNoteLoadingBayAudit
            (
                Document_id,
                OldLoadingBay,
                NewLoadingBay,
                AuditAction,
                AuditDate,
                AuditBy,
                Comments
            )
            VALUES
            (
                @DocumentID,
                @OldLoadingBay,
                NULL,
                'REMOVE',
                GETDATE(),
                @UserName,
                @Comments
            );
            DELETE
            FROM dbo.DeliveryNoteLoadingBay
            WHERE Document_id = @DocumentID;
        END
    END
    ELSE
    BEGIN
        RAISERROR('Invalid Action. Use ASSIGN or REMOVE.', 16, 1);
    END
END
