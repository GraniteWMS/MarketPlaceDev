CREATE TABLE [dbo].[Custom_CourierBoxDocument](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CourierBox_id] [bigint] NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[ScanDate] [datetime] NOT NULL,
	[ScannedUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[AuditDate] [datetime] NULL,
	[AuditUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Version] [smallint] NULL
) ON [PRIMARY]
