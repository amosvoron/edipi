
/*
	Table with row (record) EDI codes and other code info
*/

CREATE TABLE [dbo].[RowCodes](
	[RowCode] [char](3) NOT NULL,
	[Version] [char](5) NULL,
	[Name] [nvarchar](50) NULL,
	[TargetTable] [nvarchar](50) NULL,
	[IsGroupHeader] [bit] NOT NULL,
	[IsHeader] [bit] NOT NULL,
	[TransactionType] [char](1) NULL,
	[IsParserActive] [bit] NOT NULL,
	[IsNonData] [bit] NOT NULL,
	[Length] [int] NOT NULL,
	[IsTotal] [bit] NOT NULL,
	[Note] [nvarchar](100) NULL,
 CONSTRAINT [PK_RowCodes] PRIMARY KEY CLUSTERED 
(
	[RowCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsFileHeader]  DEFAULT ((0)) FOR [IsGroupHeader]
GO

ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsParserActive]  DEFAULT ((0)) FOR [IsParserActive]
GO

ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsNonData]  DEFAULT ((0)) FOR [IsNonData]
GO

ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_Length]  DEFAULT ((0)) FOR [Length]
GO

ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsTotal]  DEFAULT ((0)) FOR [IsTotal]
GO

-- Data: 

INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDN', N'01.00', N'Base Data New', N'IP', 0, 0, NULL, 1, 0, 151, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDO', N'01.00', N'Base Data Old', N'IP', 0, 0, NULL, 1, 0, 151, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDU', N'01.00', N'Base data update', N'IP', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'FRJ', N'01.00', N'File rejection', NULL, 0, 1, N'R', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRH', N'01.00', N'Begin transaction group', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRJ', N'01.00', N'Group rejection', NULL, 0, 1, N'R', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRT', N'01.00', N'End transaction group', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'HDR', N'01.00', N'Begin header', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IDA', N'01.00', N'IP Domain add', NULL, 0, 1, N'A', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IMN', N'01.00', N'Inherited name multi IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IMO', N'01.00', N'Inherited name multi IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'INN', N'01.00', N'Inherited name single IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'INO', N'01.00', N'Inherited name single IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IPA', N'01.00', N'Interested party add', NULL, 0, 1, N'A', 1, 0, 110, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAA', N'01.00', N'Membership agreement add', N'IPMembership', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAD', N'01.00', N'Membership agreement delete', N'IPMembership', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAN', N'01.00', N'Membership Agreement New', N'IPMembership', 0, 0, NULL, 1, 0, 83, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAO', N'01.00', N'Membership Agreement Old', N'IPMembership', 0, 0, NULL, 1, 0, 83, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAU', N'01.00', N'Membership agreement update', N'IPMembership', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MCN', N'01.00', N'Name multi IP connection new ', N'IPName', 0, 0, NULL, 1, 0, 163, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MCO', N'01.00', N'Name multi IP connection old', N'IPName', 0, 0, NULL, 1, 0, 163, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MUN', N'01.00', N'Name multi IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MUO', N'01.00', N'Name multi IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCA', N'01.00', N'Name connection add', N'IPName', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCD', N'01.00', N'Name connection delete (Multi connections only)', N'IPName', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCN', N'01.00', N'Name single IP Connection New', N'IPName', 0, 0, NULL, 1, 0, 195, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCO', N'01.00', N'Name single IP Connection old', N'IPName', 0, 0, NULL, 1, 0, 195, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCU', N'01.00', N'Name connection update', N'IPName', 0, 1, N'U', 1, 0, 164, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NPA', N'01.00', N'New patronym add', N'IPName', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTA', N'01.00', N'Nationality add', N'IPNationality', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTD', N'01.00', N'Nationality delete', N'IPNationality', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTN', N'01.00', N'Nationality of an IP new ', N'IPNationality', 0, 0, N'A', 1, 0, 75, 1, N'različne dolžine (!)')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTO', N'01.00', N'Nationality of an IP old', N'IPNationality', 0, 0, NULL, 1, 0, 0, 0, N'različne dolžine (!)')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTU', N'01.00', N'Nationality update', N'IPNationality', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUA', N'01.00', N'Name usage add', N'IPNameUsage', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUD', N'01.00', N'Name usage delete', N'IPNameUsage', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUN', N'01.00', N'Name single IP Usage New', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUO', N'01.00', N'Name single IP Usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'ONN', N'01.00', N'Other name connection new ', N'IPName', 0, 0, NULL, 1, 0, 206, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'ONO', N'01.00', N'Other name connection old', N'IPName', 0, 0, NULL, 1, 0, 206, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REA', N'01.00', N'Remark of society add', NULL, 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'RED', N'01.00', N'Remark delete', NULL, 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REN', N'01.00', N'Remarks of a society new ', NULL, 0, 0, NULL, 1, 0, 57, 0, N'še ne zaznano v uvozu')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REO', N'01.00', N'Remarks of a society old', NULL, 0, 0, NULL, 1, 0, 57, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STA', N'01.00', N'Status add', N'IPStatus', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STD', N'01.00', N'Status delete', N'IPStatus', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STN', N'01.00', N'Status of a new IP', N'IPStatus', 0, 0, NULL, 1, 0, 75, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STO', N'01.00', N'Status of an IP old', N'IPStatus', 0, 0, NULL, 1, 0, 75, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TMA', N'01.00', N'Territory of a membership agreement', N'IPMembershipTerritory', 0, 0, NULL, 1, 0, 60, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TRL', N'01.00', N'End of header', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TRS', N'01.00', N'Transaction status', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
