SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomTable](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Document_id] [bigint] NOT NULL,
	[DocumentLine_id] [bigint] NOT NULL,
	[TEST] [nchar](10) COLLATE Latin1_General_CI_AS NULL,
	[TTest2] [nchar](10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]

