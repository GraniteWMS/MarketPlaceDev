CREATE TABLE [dbo].[TrackingEntity](
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
	[ManufactureDate] [datetime] NULL
) ON [PRIMARY]
