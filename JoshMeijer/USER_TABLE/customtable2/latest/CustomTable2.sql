SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomTable2](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Barcode] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Name] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Site] [varchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[ERPLocation] [varchar](15) COLLATE Latin1_General_CI_AS NOT NULL,
	[AuditDate] [datetime] NULL,
	[AuditUser] [varchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Status] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[Type] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[Category] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[ERPIdentification] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Length] [int] NULL,
	[Width] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Barcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

