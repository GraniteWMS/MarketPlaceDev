CREATE TABLE [dbo].[PackingProcessLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogDate] [datetime] NULL,
	[LogOrigin] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[DocumentNumber] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[UserName] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[TrackingBarcode] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[Message] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[Step] [varchar](100) COLLATE Latin1_General_CI_AS NULL,
	[Success] [bit] NULL,
	[DocumentID] [bigint] NULL,
	[TransactionID] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
