
/*
	Log table with restore error messages.
*/

CREATE TABLE [dbo].[RestoreLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[ID] [int] NOT NULL,
	[HeaderID] [bigint] NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_RestoreLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RestoreLog] ADD  CONSTRAINT [DF_RestoreLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO



