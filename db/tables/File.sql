/*
	File table containing EDI file description data.
*/

CREATE TABLE [dbo].[File](
	[FileID] [int] IDENTITY(1,1) NOT NULL,
	[File] [nvarchar](128) NOT NULL,
	[SID] [int] NOT NULL,
	[ImportDate] [datetime] NOT NULL,
	[FirstRowID] [bigint] NOT NULL,
	[LastRowID] [bigint] NOT NULL,
	[Size]  AS (([LastRowID]-[FirstRowID])+(1)),
	[IsDiff] [bit] NOT NULL,
	[Note] [nvarchar](1000) NULL,
	[RefDate]  AS (case when isdate(substring([File],(1),(8)))=(1) then CONVERT([date],CONVERT([datetime],substring([File],(1),(8)),(0)),(0)) else case when (1)<=(46) then CONVERT([date],[ImportDate],(0))  end end),
 CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED 
(
	[FileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_File] UNIQUE NONCLUSTERED 
(
	[File] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_SID]  DEFAULT ((0)) FOR [SID]
GO

ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_Date]  DEFAULT (getdate()) FOR [ImportDate]
GO

ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_FirstRowID]  DEFAULT ((0)) FOR [FirstRowID]
GO

ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_LastRowID]  DEFAULT ((0)) FOR [LastRowID]
GO

ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_IsDiff]  DEFAULT ((1)) FOR [IsDiff]
GO

ALTER TABLE [dbo].[File]  WITH CHECK ADD  CONSTRAINT [FK_File_SID] FOREIGN KEY([SID])
REFERENCES [dbo].[Session] ([SID])
GO

ALTER TABLE [dbo].[File] CHECK CONSTRAINT [FK_File_SID]
GO
