/*
	Log table exclusively for database state logging
*/

CREATE TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DatabaseState] [int] NOT NULL,
 CONSTRAINT [PK_DatabaseLog] PRIMARY KEY CLUSTERED 
(
	[DatabaseLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DatabaseLog] ADD  CONSTRAINT [DF_DatabaseLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[DatabaseLog] ADD  CONSTRAINT [DF_DatabaseLog_DatabaseState]  DEFAULT ((0)) FOR [DatabaseState]
GO

ALTER TABLE [dbo].[DatabaseLog]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseLog_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO

ALTER TABLE [dbo].[DatabaseLog] CHECK CONSTRAINT [FK_DatabaseLog_DatabaseState]
GO
