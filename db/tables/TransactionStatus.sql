
/*
	Transaction statuses
*/

CREATE TABLE [dbo].[TransactionStatus](
	[Status] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_TransactionStatus] PRIMARY KEY CLUSTERED 
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Data:

INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (-1, N'ROLLED BACK', N'The processing failed. The transaction has been rolled back. The transaction is not active. ')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (0, N'IDLE', N'The transaction is in idle state and is active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (1, N'PROCESSING', N'The transaction is being processed right now. The transaction is active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (2, N'COMMITED', N'The transaction has been successfully commited. The transaction is not active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (3, N'INVALID', N'The transaction is invalid. It produces disallowed duplicates. This status means that something got wrong at the data provider. Transaction cannot be processed.')
GO
