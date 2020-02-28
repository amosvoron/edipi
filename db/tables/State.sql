
/*
	Database state codes
*/

CREATE TABLE [dbo].[State](
	[StateCode] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[StateCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Data:

INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (0, N'READY', N'The database is ready. All transactions are committed.', 1)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (1, N'PROCESSING', N'The database is processing. Some tables may get locked.', 0)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (2, N'INTERRUPTED', N'The database processing has been interrupted. Some transactions may be open.', 0)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (3, N'MAINTENANCE', N'The database is being maintained. The data may modifiy. Some transactions may be open. Some tables may get locked.', 0)
GO
