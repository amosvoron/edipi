
/*
	Table with description of transaction records.
*/

CREATE TABLE [dbo].[TransactionRecordInfo](
	[Step] [int] NOT NULL,
	[HeaderCode] [char](3) NULL,
	[RowCodes] [varchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Action] [varchar](20) NULL,
	[Tuned] [nvarchar](50) NULL,
	[MissingIndex] [nvarchar](max) NULL,
	[IsNameRecord] [bit] NOT NULL,
 CONSTRAINT [PK_ProcessingStep] PRIMARY KEY CLUSTERED 
(
	[Step] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[TransactionRecordInfo] ADD  CONSTRAINT [DF_ProcessingStep_Tuned]  DEFAULT ((0)) FOR [Tuned]
GO

ALTER TABLE [dbo].[TransactionRecordInfo] ADD  CONSTRAINT [DF_TransactionRecordInfo_IsNameRecord]  DEFAULT ((0)) FOR [IsNameRecord]
GO

ALTER TABLE [dbo].[TransactionRecordInfo]  WITH CHECK ADD  CONSTRAINT [FK_ProcessingStep_HeaderCode] FOREIGN KEY([HeaderCode])
REFERENCES [dbo].[RowCodes] ([RowCode])
GO

ALTER TABLE [dbo].[TransactionRecordInfo] CHECK CONSTRAINT [FK_ProcessingStep_HeaderCode]
GO

-- data:

INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (-10, NULL, NULL, N'HeaderUpdate', N'UPDATE', N'BAD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (10, N'IPA', N'IPA', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (20, N'IPA', N'BDN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (30, N'IPA', N'STN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (40, N'IPA', N'NCN,ONN,MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (50, N'IPA', N'MAN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (60, N'IPA', N'TMA', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (70, N'IPA', N'NTN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (80, N'IPA', N'NUN,INN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (90, N'IPA', N'MUN,IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (100, N'MAA', N'MAN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (110, N'MAA', N'TMA', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (120, N'NCA', N'NCN,ONN,MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (130, N'NCA', N'NUN,INN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (140, N'NCA', N'MUN,IMN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (150, N'NPA', N'NCN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (160, N'NPA', N'NCO+NCN', NULL, N'UPDATE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (170, N'NPA', N'NUN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (180, N'NTA', N'NTN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (190, N'NUA', N'NUN,INN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (200, N'NUA', N'MUN,IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (210, N'STA', N'STN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (220, N'BDU', N'BDN', NULL, N'UPDATE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (230, N'NTU', N'NTO', NULL, N'DELETE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (240, N'NTU', N'NTN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (250, N'MAU', N'MAO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (260, N'MAU', N'MAN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (270, N'MAU', N'TMA', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (280, N'NCU', N'NCO+NCN', NULL, N'UPDATE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (290, N'NCU', N'NCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (300, N'NCU', N'NCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (310, N'NCU', N'MCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (311, N'NCU', N'MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (320, N'NCU', N'ONO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (321, N'NCU', N'ONN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (330, N'NCU', N'MCO,ONO+NCN', NULL, N'UPDATE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (340, N'NCU', N'IMO', NULL, N'DELETE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (350, N'NCU', N'IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (360, N'NCU', N'INO', NULL, N'DELETE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (370, N'NCU', N'INN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (380, N'MAD', N'MAO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (390, N'NUD', N'INO,NUO,MUO,IMO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (400, N'NCD', N'MCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (410, N'NTD', N'NTO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (420, N'STD', N'STO', NULL, N'DELETE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (430, N'STD', N'STN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO