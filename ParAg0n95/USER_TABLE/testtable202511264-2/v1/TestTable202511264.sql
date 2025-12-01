SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TestTable202511264](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Barcode] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Qty] [decimal](19, 4) NOT NULL,
	[SerialNumber] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Value] [decimal](19, 2) NULL,
	[Batch] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ExpiryDate] [datetime] NULL,
	[OnHold] [bit] NOT NULL,
	[StockTake] [bit] NOT NULL,
	[InStock] [bit] NOT NULL,
	[MasterItem_id] [bigint] NOT NULL,
	[Location_id] [bigint] NOT NULL,
	[BelongsToEntity_id] [bigint] NULL,
	[GUID] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Barcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

