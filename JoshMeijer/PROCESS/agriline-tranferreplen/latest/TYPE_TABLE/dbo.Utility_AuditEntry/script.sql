CREATE TYPE [dbo].[Utility_AuditEntry] AS TABLE(
	[RecordID] [bigint] NOT NULL,
	[RecordVersion] [smallint] NULL,
	[ColumnName] [varchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[PreviousValue] [varchar](max) COLLATE Latin1_General_CI_AS NULL,
	[NewValue] [varchar](max) COLLATE Latin1_General_CI_AS NULL
)