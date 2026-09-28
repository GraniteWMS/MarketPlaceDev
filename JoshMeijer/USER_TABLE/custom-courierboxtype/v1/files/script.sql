CREATE TABLE [dbo].[Custom_CourierBoxType](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Description] [varchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[Length] [decimal](19, 6) NOT NULL,
	[Width] [decimal](19, 6) NOT NULL,
	[Height] [decimal](19, 6) NOT NULL,
	[DimensionUOM] [varchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[MaxWeight] [decimal](19, 6) NULL,
	[WeightUOM] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[AuditDate] [datetime] NULL,
	[AuditUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Version] [smallint] NULL
) ON [PRIMARY]
