CREATE TABLE [dbo].[Custom_TrackingEntityAllocation](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Document_id] [bigint] NULL,
	[DocumentLine_id] [bigint] NULL,
	[TrackingEntity_id] [bigint] NOT NULL,
	[Qty] [decimal](19, 4) NOT NULL,
	[Status] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Batch] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[User] [varchar](50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
