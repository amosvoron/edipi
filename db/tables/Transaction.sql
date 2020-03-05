
/*
	Transaction table which provides information about the EDI transaction status 
	for every block of imported data identified by HeaderID.
*/

CREATE TABLE [dbo].[Transaction](
	[HeaderID] [bigint] NOT NULL,
	[SID] [int] NOT NULL,
	[HeaderCode] [char](3) NOT NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[TransactionStatus] [int] NOT NULL,
	[Duration]  AS (case when [EndTime] IS NULL then (0) else datediff(millisecond,[BeginTime],[EndTime]) end),
	[IsReprocess] [bit] NOT NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[HeaderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Transaction] ADD  CONSTRAINT [DF_Transaction_TransactionStatus]  DEFAULT ((0)) FOR [TransactionStatus]
GO

ALTER TABLE [dbo].[Transaction] ADD  DEFAULT ((0)) FOR [IsReprocess]
GO

ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_HeaderCode] FOREIGN KEY([HeaderCode])
REFERENCES [dbo].[RowCodes] ([RowCode])
GO

ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_HeaderCode]
GO

--  Do not create association with dbo.Row
--ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_HeaderID] FOREIGN KEY([HeaderID])
--REFERENCES [dbo].[Row] ([RowID])
--ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_HeaderID]
--GO

ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_SID] FOREIGN KEY([SID])
REFERENCES [dbo].[Session] ([SID])
GO

ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_SID]
GO

ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_TransactionStatus] FOREIGN KEY([TransactionStatus])
REFERENCES [dbo].[TransactionStatus] ([Status])
GO

ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_TransactionStatus]
GO
