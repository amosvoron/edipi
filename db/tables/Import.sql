/*
	Raw import table where the rows from EDI file are stored.
*/

CREATE TABLE [dbo].[Import](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[HeaderID] [bigint] NULL,
	[RowCode] [char](3) NULL,
	[HeaderCode] [char](3) NULL,
	[HeaderSeq] [char](5) NULL,
	[Version] [char](5) NULL,
	[IsHeader] [bit] NOT NULL,
	[Row] [nvarchar](500) NOT NULL,
	[IsParsed] [bit] NOT NULL,
	[FileID] [int] NULL,
	[ErrorID] [int] NOT NULL,
 CONSTRAINT [PK_Import] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_IsHeaderParsed]  DEFAULT ((0)) FOR [IsHeader]
GO

ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_IsRecordParsed]  DEFAULT ((0)) FOR [IsParsed]
GO

ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_ErrorID]  DEFAULT ((0)) FOR [ErrorID]
GO
