
/*
	Table with row and header codes
*/

CREATE TABLE [dbo].[RowHeader](
	[RowID] [bigint] NOT NULL,
	[RowCode] [char](3) NOT NULL,
	[HeaderID] [bigint] NULL,
	[HeaderCode] [char](3) NULL,
 CONSTRAINT [PK_RowHeader] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO









