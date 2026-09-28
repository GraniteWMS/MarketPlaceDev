CREATE TABLE [dbo].[DeliveryNoteLoadingBayAudit](
	[AuditID] [bigint] IDENTITY(1,1) NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[OldLoadingBay] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[NewLoadingBay] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[AuditAction] [varchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[AuditDate] [datetime] NOT NULL,
	[AuditBy] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[Comments] [varchar](500) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
