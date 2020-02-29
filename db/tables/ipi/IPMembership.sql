
/*
	Membership agreement entity
	    Holds the membership agreements of IP's with their IPI administration societies
*/

CREATE TABLE [ipi].[IPMembership](
	[MID] [bigint] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[ID] [int] NOT NULL,
	[SocietyCode] [char](3) NULL,
	[SocietyName] [nchar](20) NULL,
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
	[NID] [int] NULL,
 CONSTRAINT [PK_IPMembership] PRIMARY KEY CLUSTERED 
(
	[MID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPMembership]  WITH CHECK ADD  CONSTRAINT [FK_IPMembership_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO

ALTER TABLE [ipi].[IPMembership] CHECK CONSTRAINT [FK_IPMembership_ID]
GO
