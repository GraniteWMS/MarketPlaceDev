CREATE TABLE [dbo].[custom_DocumentTrackingLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Document] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Version] [int] NOT NULL,
	[TrackingStatus] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[User] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ActivityDate] [datetime] NOT NULL,
	[Comment] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[DocumentReference] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[IntegrationReference] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[Process] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[AdditionalData] [varchar](250) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
