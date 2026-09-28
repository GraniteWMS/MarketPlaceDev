CREATE TABLE [dbo].[Custom_CourierBox](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CourierBoxType_id] [bigint] NULL,
	[BoxBarcode] [varchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[Weight] [decimal](19, 6) NULL,
	[WeightUOM] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[VolumetricWeight] [decimal](19, 6) NULL,
	[ScanDate] [datetime] NULL,
	[ScannedUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[IsFinalised] [bit] NOT NULL,
	[FinalisedDate] [datetime] NULL,
	[FinalisedUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Comment] [varchar](250) COLLATE Latin1_General_CI_AS NULL,
	[AuditDate] [datetime] NULL,
	[AuditUser] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Version] [smallint] NULL
) ON [PRIMARY]
