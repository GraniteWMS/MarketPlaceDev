SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomTable](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[DocumentLine_id] [bigint] NOT NULL,
	[TrackingEntity_id] [bigint] NOT NULL,
	[Qty] [decimal](19, 4) NOT NULL,
	[Status] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[GUID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

