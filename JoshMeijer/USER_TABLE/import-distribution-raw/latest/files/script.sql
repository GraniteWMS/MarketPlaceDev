CREATE TABLE [dbo].[Import_Distribution_Raw](
	[System ID] [varchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[Manufact. SKU] [varchar](80) COLLATE Latin1_General_CI_AS NULL,
	[Item] [varchar](200) COLLATE Latin1_General_CI_AS NULL,
	[Order Qty.] [decimal](18, 3) NULL,
	[WH_ALP] [decimal](18, 3) NULL,
	[WH_BAT] [decimal](18, 3) NULL,
	[WH_BH] [decimal](18, 3) NULL,
	[WH_EC] [decimal](18, 3) NULL,
	[WH_FOR] [decimal](18, 3) NULL,
	[WH_MID] [decimal](18, 3) NULL,
	[WH_PTC] [decimal](18, 3) NULL,
	[WH_UGA] [decimal](18, 3) NULL,
	[BACKSTOCK] [decimal](18, 3) NULL
) ON [PRIMARY]
