
/*
	Log table with errors and OK messages.
*/

CREATE TABLE [dbo].[Log](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[SID] [int] NOT NULL,
	[IsOK] [bit] NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[InterruptedID] [int] NULL,
	[DatabaseState] [int] NOT NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_DatabaseState]  DEFAULT ((0)) FOR [DatabaseState]
GO

ALTER TABLE [dbo].[Log]  WITH CHECK ADD  CONSTRAINT [FK_Log_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO

ALTER TABLE [dbo].[Log] CHECK CONSTRAINT [FK_Log_DatabaseState]
GO



