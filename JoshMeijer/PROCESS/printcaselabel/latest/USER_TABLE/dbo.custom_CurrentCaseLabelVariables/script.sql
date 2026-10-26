CREATE TABLE [dbo].[custom_CurrentCaseLabelVariables](
	[MasterItemCode] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[JulianDate] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[Plant] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[BBDate] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[GS1Human] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[GS1Barcode] [varchar](50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
