CREATE TABLE [dbo].[Custom_CarryingEntityAllocation](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[User] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Document_id] [bigint] NOT NULL,
	[DocumentNumber] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[CarryingEntityBarcode] [varchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Date] [datetime] NOT NULL
) ON [PRIMARY]
