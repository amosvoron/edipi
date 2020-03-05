
/*
	Interruption table with detailed info about the interruptions of the process.
*/

CREATE TABLE [dbo].[Interrupted](
	[InterruptedID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[SID] [int] NOT NULL,
	[HeaderID] [bigint] NULL,
	[Message] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Interrupted] PRIMARY KEY CLUSTERED 
(
	[InterruptedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Interrupted] ADD  CONSTRAINT [DF_Interrupted_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[Interrupted]  WITH CHECK ADD  CONSTRAINT [FK_Interrupted_SID] FOREIGN KEY([SID])
REFERENCES [dbo].[Session] ([SID])
GO

ALTER TABLE [dbo].[Interrupted] CHECK CONSTRAINT [FK_Interrupted_SID]
GO


