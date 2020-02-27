/*
	Configuration table:
		- DiffPath: A path where differential files are stored.
		- DatabaseState: The current database state.
		- LastCommitedHeaderID: HeaderID of the last commited transaction (in EDI transaction chain).
*/

CREATE TABLE [dbo].[Config](
	[DiffPath] [nvarchar](260) NOT NULL,
	[DatabaseState] [int] NOT NULL,
	[LastCommitedHeaderID] [bigint] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Config]  WITH CHECK ADD  CONSTRAINT [FK_Config_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO

ALTER TABLE [dbo].[Config] CHECK CONSTRAINT [FK_Config_DatabaseState]
GO

ALTER TABLE [dbo].[Config]  WITH CHECK ADD  CONSTRAINT [FK_Config_LastCommitedTransactionID] FOREIGN KEY([LastCommitedHeaderID])
REFERENCES [dbo].[Row] ([RowID])
GO

ALTER TABLE [dbo].[Config] CHECK CONSTRAINT [FK_Config_LastCommitedTransactionID]
GO
