CREATE TABLE [dbo].[Custom_TaskList](
	[TaskID] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskName] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[TaskDescription] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[UserID] [bigint] NULL,
	[TrackingEntityID] [bigint] NULL,
	[LocationID] [bigint] NULL,
	[MasterItemID] [bigint] NULL,
	[DocumentID] [bigint] NULL,
	[AuditUserID] [bigint] NULL,
	[AuditDate] [datetime] NULL,
	[Status] [varchar](20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
