
/*
	IP name entity
	    Contains the names of interested parties.
*/

CREATE TABLE [ipi].[IPName](
	[NID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RowID] [bigint] NOT NULL,
	[ID] [int] NOT NULL,
	[IPNN] [char](11) NULL,
	[NameType] [char](2) NULL,
	[Name] [nvarchar](90) NULL,
	[FirstName] [nvarchar](50) NULL,
	[AmendDate] [char](8) NULL,
	[AmendTime] [char](6) NULL,
	[CreationDate] [char](8) NULL,
	[CreationTime] [char](6) NULL,
	[FullName_B]  AS (rtrim(ltrim((rtrim(isnull([Name],''))+' ')+ltrim(isnull([FirstName],''))))),
 CONSTRAINT [PK_IPName] PRIMARY KEY CLUSTERED 
(
	[NID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPName]  WITH CHECK ADD  CONSTRAINT [FK_IPName_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO

ALTER TABLE [ipi].[IPName] CHECK CONSTRAINT [FK_IPName_ID]
GO
