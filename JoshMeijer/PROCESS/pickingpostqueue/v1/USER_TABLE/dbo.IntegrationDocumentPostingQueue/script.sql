CREATE TABLE [dbo].[IntegrationDocumentPostingQueue](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERP_id] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[DocumentNumber] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[DocumentType] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Status] [varchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[LastUpdateDateTime] [datetime] NOT NULL,
	[IntegrationDateTime] [datetime] NULL
) ON [PRIMARY]
