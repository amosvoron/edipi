
/*
	Status of an IP entity
	    There is at all points in time at least one "Status of an IP" per IP.
*/

CREATE TABLE [ipi].[IPStatus](
	[SID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[ID] [int] NOT NULL,
	[RefID] [int] NOT NULL,
	[StatusCode] [char](1) NOT NULL,
	[ValidFromDate] [char](8) NULL,
	[ValidFromTime] [char](6) NULL,
	[ValidToDate] [char](8) NULL,
	[ValidToTime] [char](6) NULL,
	[AmendDate] [char](8) NULL,
	[AmendTime] [char](6) NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[SID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ipi].[IPStatus]  WITH CHECK ADD  CONSTRAINT [FK_IPStatus_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO

ALTER TABLE [ipi].[IPStatus] CHECK CONSTRAINT [FK_IPStatus_ID]
GO

ALTER TABLE [ipi].[IPStatus]  WITH CHECK ADD  CONSTRAINT [FK_IPStatus_RefID] FOREIGN KEY([RefID])
REFERENCES [ipi].[IP] ([ID])
GO

ALTER TABLE [ipi].[IPStatus] CHECK CONSTRAINT [FK_IPStatus_RefID]
GO
