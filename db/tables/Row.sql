
/*
	Table with raw data
*/

CREATE TABLE [dbo].[Row](
	[RowID] [bigint] NOT NULL,
	[HeaderID] [bigint] NULL,
	[HeaderCode] [char](3) NULL,
	[RowCode] [char](3) NOT NULL,
	[TranSeq] [char](8) NULL,
	[RecordSeq] [char](8) NULL,
	[TranDate] [char](8) NULL,
	[TranTime] [char](6) NULL,
	[SocietyCode] [char](3) NULL,
	[SocietyName] [nchar](20) NULL,
	[IPBN] [char](13) NULL,
	[StatusCode] [char](1) NULL,
	[IPNN] [char](11) NULL,
	[NameType] [char](2) NULL,
	[IPBNRef] [char](13) NULL,
	[StatusCodeRef] [char](1) NULL,
	[IPNNRef] [char](11) NULL,
	[NameTypeRef] [char](2) NULL,
	[CCCode] [char](2) NULL,
	[RoleCode] [char](2) NULL,
	[RightCode] [char](2) NULL,
	[ValidFromDate] [char](8) NULL,
	[ValidFromTime] [char](6) NULL,
	[ValidToDate] [char](8) NULL,
	[ValidToTime] [char](6) NULL,
	[SignDate] [char](8) NULL,
	[MemberShare] [char](5) NULL,
	[AmendDate] [char](8) NULL,
	[AmendTime] [char](6) NULL,
	[IPBNNew] [char](13) NULL,
	[StatusCodeNew] [char](1) NULL,
	[IPNNNew] [char](11) NULL,
	[NameTypeNew] [char](2) NULL,
	[IPBNRefNew] [char](13) NULL,
	[StatusCodeRefNew] [char](1) NULL,
	[IPNNRefNew] [char](11) NULL,
	[NameTypeRefNew] [char](2) NULL,
	[Type] [char](1) NULL,
	[BirthDate] [char](8) NULL,
	[DeathDate] [char](8) NULL,
	[BirthPlace] [char](30) NULL,
	[BirthState] [char](30) NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[IEIndicator] [char](1) NULL,
	[Sex] [char](1) NULL,
	[Name] [nvarchar](90) NULL,
	[FirstName] [nvarchar](50) NULL,
	[CreationDate] [char](8) NULL,
	[CreationTime] [char](6) NULL,
	[Sequence] [char](4) NULL,
	[Note] [nvarchar](20) NULL,
 CONSTRAINT [PK_Row] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO


