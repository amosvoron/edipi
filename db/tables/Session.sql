
/*
	Session table that provides SID for every import action
*/

CREATE TABLE [dbo].[Session](
	[SID] [int] IDENTITY(1,1) NOT NULL,
	[BeginTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[Note] [nvarchar](50) NULL,
	[Duration]  AS (case when [EndTime] IS NULL then (0) else datediff(second,[BeginTime],[EndTime]) end),
	[DurationMin]  AS (CONVERT([char](8),dateadd(second,case when [EndTime] IS NULL then (0) else datediff(second,[BeginTime],[EndTime]) end,(0)),(108))),
	[IsClosed]  AS (case when [EndTime] IS NULL then (0) else (1) end),
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[SID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Session] ADD  CONSTRAINT [DF_Session_BeginProcessing]  DEFAULT (getdate()) FOR [BeginTime]
GO


