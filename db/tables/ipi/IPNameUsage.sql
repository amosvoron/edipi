
/*
	Name usage entity
	    Name usage is the connection of IP names to IP activities: creation classes, roles and rights.
*/

CREATE TABLE [ipi].[IPNameUsage](
	[NUID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RowID] [bigint] NOT NULL,
	[NID] [int] NOT NULL,
	[CCCode] [char](2) NULL,
	[RoleCode] [char](2) NULL,
 CONSTRAINT [PK_IPNameUsage] PRIMARY KEY CLUSTERED 
(
	[NUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPNameUsage]  WITH CHECK ADD  CONSTRAINT [FK_IPNameUsage_NID] FOREIGN KEY([NID])
REFERENCES [ipi].[IPName] ([NID])
ON DELETE CASCADE
GO

ALTER TABLE [ipi].[IPNameUsage] CHECK CONSTRAINT [FK_IPNameUsage_NID]
GO
