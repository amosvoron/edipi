
/*
	Nationality of an IP entity
	    An IP, natural persons only (type of interested party), may have no, one or more nationalities 
		at any point in time.
*/

CREATE TABLE [ipi].[IPNationality](
	[NTID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[ID] [int] NOT NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[ValidFrom] [char](8) NULL,
	[ValidTo] [char](8) NULL,
 CONSTRAINT [PK_IPNationality] PRIMARY KEY CLUSTERED 
(
	[NTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPNationality]  WITH CHECK ADD  CONSTRAINT [FK_IPNationality_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO

ALTER TABLE [ipi].[IPNationality] CHECK CONSTRAINT [FK_IPNationality_ID]
GO
