CREATE TABLE [dbo].[custom_LogMessages](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Message] [varchar](max) COLLATE Latin1_General_CI_AS NULL,
	[Date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
