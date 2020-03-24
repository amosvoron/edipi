
/*
	Table with restore data
*/

CREATE TABLE [dbo].[Restore](
	[ID] [int] NOT NULL,
	[CanRestore] [bit] NOT NULL,
	[IsProcessing] [bit] NOT NULL,
	[MembershipOldCount] [int] NULL,
	[MembershipNewCount] [int] NULL,
	[MembershipTerritoryOldCount] [int] NULL,
	[MembershipTerritoryNewCount] [int] NULL,
	[ForProcessing] [bit] NOT NULL,
 CONSTRAINT [PK_Restore] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Restore] ADD  CONSTRAINT [DF_Restore_IsProcessing]  DEFAULT ((0)) FOR [IsProcessing]
GO

ALTER TABLE [dbo].[Restore] ADD  DEFAULT ((0)) FOR [ForProcessing]
GO



