CREATE TABLE [dbo].[DeliveryNoteLoadingBay](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[LoadingBay] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[AssignedDate] [datetime] NOT NULL,
	[AssignedBy] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[Comments] [varchar](500) COLLATE Latin1_General_CI_AS NULL,
	[RowVer] [timestamp] NOT NULL
) ON [PRIMARY]
