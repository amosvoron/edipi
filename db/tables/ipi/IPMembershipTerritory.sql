
/*
	Territory of a membership agreement entity
	    A territory of a membership agreement is a single territory either within 
		the territorial scope of the agreement or excluded from it.
*/

CREATE TABLE [ipi].[IPMembershipTerritory](
	[MTID] [bigint] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[MID] [bigint] NOT NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[IEIndicator] [char](1) NULL,
 CONSTRAINT [PK_IPMembershipTerritory] PRIMARY KEY CLUSTERED 
(
	[MTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPMembershipTerritory]  WITH CHECK ADD  CONSTRAINT [FK_IPMembershipTerritory_MID] FOREIGN KEY([MID])
REFERENCES [ipi].[IPMembership] ([MID])
ON DELETE CASCADE
GO

ALTER TABLE [ipi].[IPMembershipTerritory] CHECK CONSTRAINT [FK_IPMembershipTerritory_MID]
GO
