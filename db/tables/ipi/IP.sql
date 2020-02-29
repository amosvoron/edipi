
/*
	Interested Party entity
	    Represents either a natural person or a legal entity
*/

CREATE TABLE [ipi].[IP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[IPBN] [char](13) NULL,
	[Type] [char](1) NULL,
	[BirthDate] [char](8) NULL,
	[DeathDate] [char](8) NULL,
	[BirthPlace] [varchar](30) NULL,
	[BirthState] [varchar](30) NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[IEIndicator] [char](1) NULL,
	[Sex] [char](1) NULL,
	[AmendDate] [char](8) NULL,
	[AmendTime] [char](6) NULL,
 CONSTRAINT [PK_IP] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO


