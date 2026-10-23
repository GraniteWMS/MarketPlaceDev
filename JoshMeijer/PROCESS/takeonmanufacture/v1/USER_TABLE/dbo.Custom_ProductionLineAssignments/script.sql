CREATE TABLE [dbo].[Custom_ProductionLineAssignments](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductionLine] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[MasterItem] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[PreformMasterItem] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[IsActive] [bit] NULL,
	[AssignedDate] [datetime] NULL,
	[User] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[CurrentBatch] [varchar](10) COLLATE Latin1_General_CI_AS NULL,
	[PalletsPerBatch] [int] NULL,
	[BottlesPerPallet] [int] NULL,
	[CurrentJob] [varchar](30) COLLATE Latin1_General_CI_AS NULL,
	[PalletsProduced] [int] NULL
) ON [PRIMARY]
