CREATE TABLE [dbo].[OptionalFieldValues_DocumentDetail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Value] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[OptionalField_id] [bigint] NULL,
	[BelongsTo_id] [bigint] NULL
) ON [PRIMARY]
