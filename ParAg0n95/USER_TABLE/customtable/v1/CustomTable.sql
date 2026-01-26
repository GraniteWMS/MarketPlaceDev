SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomTable](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[DocumentLine_id] [bigint] NOT NULL,
	[TrackingEntity_id] [bigint] NOT NULL,
	[Test] [nchar](10) COLLATE Latin1_General_CI_AS NULL,
	[Test32] [nchar](10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]

