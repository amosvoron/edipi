/*********************************************************************************************

	  EXECUTE THIS SCRIPT IN A NEWLY CREATED (EMPTY) DATABASE WITH sysadmin PERMISSIONS!

**********************************************************************************************/


/****** Object:  Schema [ipi]    Script Date: 16. 04. 2020 23:22:06 ******/
CREATE SCHEMA [ipi]
GO
/****** Object:  UserDefinedFunction [dbo].[ComputeNextFile]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.CheckNextFile
Description:	Checks the existance of the consecutive file.
				------------------------------------------------------------------
Note:			The consecutive file must exists in order to start the import.
				All files have to be imported in the CORRECT date order otherwise
				the database will get compromised.
				------------------------------------------------------------------
Logic:			
					1. Compute next file (name).
					2. Check whether the next file is needed:
						- NOT NULL:  next file is returned
						- NULL:		 next import is not needed
*/

CREATE FUNCTION [dbo].[ComputeNextFile]()
RETURNS nvarchar(128)
AS BEGIN

	DECLARE @NextDay AS datetime = DATEADD(DAY, 1, (SELECT RefDate FROM dbo.LastFile));

	-- check if next day is greater than today
	IF @NextDay >= CAST(CAST(GETDATE() AS DATE) AS datetime)
	BEGIN
		RETURN NULL;	-- import not needed
	END;

	DECLARE @NextFile AS nvarchar(128) = REPLACE(CONVERT(char(10), @NextDay, 126), '-', '') + '.IPI';
	RETURN @NextFile;	

END;





GO
/****** Object:  UserDefinedFunction [dbo].[FileExists]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.FileExists
Description:		Returns 1 if specified file within @path exists.
*/

CREATE FUNCTION [dbo].[FileExists](@path varchar(512))
RETURNS bit
AS
BEGIN
     DECLARE @result int;
     EXEC [master].dbo.xp_fileexist @path, @result OUTPUT;
     RETURN CAST(@result as bit);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[FirstNonProcessedHeaderID]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.FirstNonProcessedHeaderID
Description:		Returns the first non-processed transaction (HeaderID).
*/

CREATE FUNCTION [dbo].[FirstNonProcessedHeaderID]()
RETURNS bigint
AS
BEGIN
    RETURN (
		SELECT TOP(1) [HeaderID]
		FROM [dbo].[Transaction]
		WHERE [TransactionStatus] < 2
		ORDER BY HeaderID ASC);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetContextData]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.GetContectData
Description:	Read data from CONTECT_INFO function as set by adm.SetContextData procedure
				and returns varchar(128) string.
*/

CREATE FUNCTION [dbo].[GetContextData] ()
RETURNS varchar(128)

AS 
BEGIN 

	DECLARE @Data As varchar(128);

	SELECT @Data =
			CASE WHEN A.Data = 0x0 THEN NULL ELSE  Cast(A.Data As varchar(128)) END
			FROM ( SELECT CONTEXT_INFO() As Data ) As A;
	
	RETURN @Data;

END



GO
/****** Object:  UserDefinedFunction [dbo].[GetDatabaseState]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.GetDatabaseState
Description:		Returns the current state of the database.
*/

CREATE FUNCTION [dbo].[GetDatabaseState]()
RETURNS int
AS
BEGIN
    RETURN (
		SELECT TOP(1) [DatabaseState] 
		FROM [dbo].[Config]
	);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[GetLastSID]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.GetLastSID
Description:	Gets last SID.
*/

CREATE FUNCTION [dbo].[GetLastSID] ()
RETURNS int
AS 
BEGIN 

	RETURN (SELECT TOP(1) [SID]
		FROM dbo.[Session]
		ORDER BY [SID] DESC);

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetSID]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.GetSID
Description:	Gets current SID.
*/

CREATE FUNCTION [dbo].[GetSID] ()
RETURNS int

AS 
BEGIN 

	DECLARE @Data AS varchar(128) = dbo.GetContextData();
	DECLARE @SID AS int = 0;
	IF ISNUMERIC(@Data) = 1
	BEGIN
		SET @SID = CAST(@Data AS int)
	END;

	RETURN @SID;

END

GO
/****** Object:  UserDefinedFunction [dbo].[IsActive]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.IsActive
Description:		Returns 1 if the transaction is active.
					Non-existing transaction is considered as inactive.
*/

CREATE FUNCTION [dbo].[IsActive](@HeaderID bigint)
RETURNS bigint
AS
BEGIN
    RETURN ISNULL((
		SELECT 
			CASE WHEN TransactionStatus = 2 THEN 0
			ELSE 1 END AS IsActive
		FROM [dbo].[Transaction]
		WHERE HeaderID = @HeaderID
	), 0);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[IsProcessing]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.IsProcessing
Description:		Returns 1 if the database state is PROCESSING.
*/

CREATE FUNCTION [dbo].[IsProcessing]()
RETURNS bit
AS
BEGIN
    RETURN (CASE WHEN dbo.GetDatabaseState() = 1 THEN 1 ELSE 0 END);
END;

GO
/****** Object:  UserDefinedFunction [dbo].[IsReady]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.IsReady
Description:		Returns 1 if the database state is READY.
*/

CREATE FUNCTION [dbo].[IsReady]()
RETURNS bit
AS
BEGIN
    RETURN (CASE WHEN dbo.GetDatabaseState() = 0 THEN 1 ELSE 0 END);
END;

GO
/****** Object:  UserDefinedFunction [dbo].[IsSessionValid]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.IsSessionValid
Description:	Returns 1 if sesion variable equals the last SID from dbo.Session table.
*/

CREATE FUNCTION [dbo].[IsSessionValid]()
RETURNS int

AS 
BEGIN 

	RETURN 
		CASE WHEN dbo.GetSID() = dbo.GetLastSID() THEN 1
		ELSE 0 END;

END

GO
/****** Object:  Table [dbo].[Import]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Import](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[HeaderID] [bigint] NULL,
	[RowCode] [char](3) NULL,
	[HeaderCode] [char](3) NULL,
	[HeaderSeq] [char](5) NULL,
	[Version] [char](5) NULL,
	[IsHeader] [bit] NOT NULL,
	[Row] [nvarchar](500) NOT NULL,
	[IsParsed] [bit] NOT NULL,
	[FileID] [int] NULL,
	[ErrorID] [int] NOT NULL,
 CONSTRAINT [PK_Import] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ToImport]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	View as import destination
*/

CREATE VIEW [dbo].[ToImport]
AS

SELECT [Row] FROM dbo.Import;

GO
/****** Object:  Table [ipi].[IP]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ipi].[IP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [bigint] NOT NULL,
	[IPBN] [char](13) NULL,
	[Type] [char](1) NULL,
	[BirthDate] [char](8) NULL,
	[DeathDate] [char](8) NULL,
	[BirthPlace] [varchar](30) NULL,
	[BirthState] [varchar](30) NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[IEIndicator] [char](1) NULL,
	[Sex] [char](1) NULL,
	[AmendDate] [char](8) NULL,
	[AmendTime] [char](6) NULL,
 CONSTRAINT [PK_IP] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ipi].[IPName]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ipi].[IPName](
	[NID] [int] IDENTITY(1,1) NOT NULL,
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
/****** Object:  Table [ipi].[IPNationality]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [ipi].[IPStatus]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [ipi].[IPMembership]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [ipi].[IPMembershipTerritory]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [ipi].[IPNameUsage]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ipi].[IPNameUsage](
	[NUID] [int] IDENTITY(1,1) NOT NULL,
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
/****** Object:  Table [dbo].[Row]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Row](
	[RowID] [bigint] NOT NULL,
	[HeaderID] [bigint] NULL,
	[HeaderCode] [char](3) NULL,
	[RowCode] [char](3) NOT NULL,
	[TranSeq] [char](8) NULL,
	[RecordSeq] [char](8) NULL,
	[TranDate] [char](8) NULL,
	[TranTime] [char](6) NULL,
	[SocietyCode] [char](3) NULL,
	[SocietyName] [nchar](20) NULL,
	[IPBN] [char](13) NULL,
	[StatusCode] [char](1) NULL,
	[IPNN] [char](11) NULL,
	[NameType] [char](2) NULL,
	[IPBNRef] [char](13) NULL,
	[StatusCodeRef] [char](1) NULL,
	[IPNNRef] [char](11) NULL,
	[NameTypeRef] [char](2) NULL,
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
	[IPBNNew] [char](13) NULL,
	[StatusCodeNew] [char](1) NULL,
	[IPNNNew] [char](11) NULL,
	[NameTypeNew] [char](2) NULL,
	[IPBNRefNew] [char](13) NULL,
	[StatusCodeRefNew] [char](1) NULL,
	[IPNNRefNew] [char](11) NULL,
	[NameTypeRefNew] [char](2) NULL,
	[Type] [char](1) NULL,
	[BirthDate] [char](8) NULL,
	[DeathDate] [char](8) NULL,
	[BirthPlace] [char](30) NULL,
	[BirthState] [char](30) NULL,
	[TISN] [char](4) NULL,
	[TISNValidFrom] [char](8) NULL,
	[TISAN] [char](20) NULL,
	[TISANValidFrom] [char](8) NULL,
	[IEIndicator] [char](1) NULL,
	[Sex] [char](1) NULL,
	[Name] [nvarchar](90) NULL,
	[FirstName] [nvarchar](50) NULL,
	[CreationDate] [char](8) NULL,
	[CreationTime] [char](6) NULL,
	[Sequence] [char](4) NULL,
	[Note] [nvarchar](20) NULL,
 CONSTRAINT [PK_Row] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Statistics]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	Count statistics
*/

CREATE VIEW [dbo].[Statistics]
AS

SELECT 'dbo.Row' AS [Table], COUNT(*) AS 'Count' FROM [dbo].[Row]
UNION ALL
SELECT 'ipi.IP', COUNT(*) FROM [ipi].[IP]
UNION ALL
SELECT 'ipi.IPName', COUNT(*) FROM [ipi].[IPName]
UNION ALL
SELECT 'ipi.IPNameUsage', COUNT(*) FROM [ipi].[IPNameUsage]
UNION ALL
SELECT 'ipi.IPMembership', COUNT(*) FROM [ipi].[IPMembership]
UNION ALL
SELECT 'ipi.IPMembershipTerritory', COUNT(*) FROM [ipi].[IPMembershipTerritory]
UNION ALL
SELECT 'ipi.IPNationality', COUNT(*) FROM [ipi].[IPNationality]
UNION ALL
SELECT 'ipi.IPStatus', COUNT(*) FROM [ipi].[IPStatus]



GO
/****** Object:  Table [dbo].[File]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[File](
	[FileID] [int] IDENTITY(1,1) NOT NULL,
	[File] [nvarchar](128) NOT NULL,
	[SID] [int] NULL,
	[ImportDate] [datetime] NOT NULL,
	[FirstRowID] [bigint] NOT NULL,
	[LastRowID] [bigint] NOT NULL,
	[Size]  AS (([LastRowID]-[FirstRowID])+(1)),
	[IsDiff] [bit] NOT NULL,
	[Note] [nvarchar](1000) NULL,
	[RefDate]  AS (case when isdate(substring([File],(1),(8)))=(1) then CONVERT([date],CONVERT([datetime],substring([File],(1),(8)),(0)),(0)) else case when (1)<=(46) then CONVERT([date],[ImportDate],(0))  end end),
 CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED 
(
	[FileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[LastFile]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Return last file row
*/

CREATE VIEW [dbo].[LastFile] 
AS

SELECT TOP(1)
	FileID, [File], ImportDate, RefDate, FirstRowID, LastRowID, IsDiff, Note
FROM dbo.[File]
ORDER BY FileID DESC;

GO
/****** Object:  Table [dbo].[RowCodes]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RowCodes](
	[RowCode] [char](3) NOT NULL,
	[Version] [char](5) NULL,
	[Name] [nvarchar](50) NULL,
	[TargetTable] [nvarchar](50) NULL,
	[IsGroupHeader] [bit] NOT NULL,
	[IsHeader] [bit] NOT NULL,
	[TransactionType] [char](1) NULL,
	[IsParserActive] [bit] NOT NULL,
	[IsNonData] [bit] NOT NULL,
	[Length] [int] NOT NULL,
	[IsTotal] [bit] NOT NULL,
	[Note] [nvarchar](100) NULL,
 CONSTRAINT [PK_RowCodes] PRIMARY KEY CLUSTERED 
(
	[RowCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UnparsedRowCodes]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Return unparsed rows from dbo.Import
*/

CREATE VIEW [dbo].[UnparsedRowCodes] 
AS

SELECT DISTINCT A.RowCode
	, CASE WHEN B.RowCode IS NULL THEN 'NO PARSER' 
		ELSE CASE WHEN B.IsParserActive = 0 THEN 'INACTIVE PARSER'
			ELSE 'NOT PARSED' END END AS Reason
FROM dbo.Import AS A
LEFT OUTER JOIN dbo.RowCodes AS B ON A.RowCode = B.RowCode
WHERE A.IsParsed = 0
	AND B.[IsGroupHeader] = 0;

GO
/****** Object:  Table [dbo].[Config]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Config](
	[DiffPath] [nvarchar](260) NOT NULL,
	[DatabaseState] [int] NOT NULL,
	[LastCommitedHeaderID] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DatabaseLog]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DatabaseState] [int] NOT NULL,
 CONSTRAINT [PK_DatabaseLog] PRIMARY KEY CLUSTERED 
(
	[DatabaseLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Interrupted]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[Log]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[Restore]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[RestoreLog]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RestoreLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[ID] [int] NOT NULL,
	[HeaderID] [bigint] NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_RestoreLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RowHeader]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RowHeader](
	[RowID] [bigint] NOT NULL,
	[RowCode] [char](3) NOT NULL,
	[HeaderID] [bigint] NULL,
	[HeaderCode] [char](3) NULL,
 CONSTRAINT [PK_RowHeader] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Session]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[State]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State](
	[StateCode] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[StateCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transaction]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transaction](
	[HeaderID] [bigint] NOT NULL,
	[SID] [int] NOT NULL,
	[HeaderCode] [char](3) NOT NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[TransactionStatus] [int] NOT NULL,
	[Duration]  AS (case when [EndTime] IS NULL then (0) else datediff(millisecond,[BeginTime],[EndTime]) end),
	[IsReprocess] [bit] NOT NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[HeaderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionRecordInfo]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionRecordInfo](
	[Step] [int] NOT NULL,
	[HeaderCode] [char](3) NULL,
	[RowCodes] [varchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Action] [varchar](20) NULL,
	[Tuned] [nvarchar](50) NULL,
	[MissingIndex] [nvarchar](max) NULL,
	[IsNameRecord] [bit] NOT NULL,
 CONSTRAINT [PK_ProcessingStep] PRIMARY KEY CLUSTERED 
(
	[Step] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionStatus]    Script Date: 16. 04. 2020 23:22:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionStatus](
	[Status] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_TransactionStatus] PRIMARY KEY CLUSTERED 
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Log] ON 
GO
INSERT [dbo].[Log] ([LogID], [Timestamp], [SID], [IsOK], [Message], [InterruptedID], [DatabaseState]) VALUES (1, CAST(N'2020-03-05T15:03:26.673' AS DateTime), 0, 1, N'The database is initialized.', NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[Log] OFF
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDN', N'01.00', N'Base Data New', N'IP', 0, 0, NULL, 1, 0, 151, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDO', N'01.00', N'Base Data Old', N'IP', 0, 0, NULL, 1, 0, 151, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'BDU', N'01.00', N'Base data update', N'IP', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'FRJ', N'01.00', N'File rejection', NULL, 0, 1, N'R', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRH', N'01.00', N'Begin transaction group', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRJ', N'01.00', N'Group rejection', NULL, 0, 1, N'R', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'GRT', N'01.00', N'End transaction group', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'HDR', N'01.00', N'Begin header', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IDA', N'01.00', N'IP Domain add', NULL, 0, 1, N'A', 0, 0, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IMN', N'01.00', N'Inherited name multi IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IMO', N'01.00', N'Inherited name multi IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'INN', N'01.00', N'Inherited name single IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'INO', N'01.00', N'Inherited name single IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'IPA', N'01.00', N'Interested party add', NULL, 0, 1, N'A', 1, 0, 110, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAA', N'01.00', N'Membership agreement add', N'IPMembership', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAD', N'01.00', N'Membership agreement delete', N'IPMembership', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAN', N'01.00', N'Membership Agreement New', N'IPMembership', 0, 0, NULL, 1, 0, 83, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAO', N'01.00', N'Membership Agreement Old', N'IPMembership', 0, 0, NULL, 1, 0, 83, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MAU', N'01.00', N'Membership agreement update', N'IPMembership', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MCN', N'01.00', N'Name multi IP connection new ', N'IPName', 0, 0, NULL, 1, 0, 163, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MCO', N'01.00', N'Name multi IP connection old', N'IPName', 0, 0, NULL, 1, 0, 163, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MUN', N'01.00', N'Name multi IP usage new', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'MUO', N'01.00', N'Name multi IP usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 47, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCA', N'01.00', N'Name connection add', N'IPName', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCD', N'01.00', N'Name connection delete (Multi connections only)', N'IPName', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCN', N'01.00', N'Name single IP Connection New', N'IPName', 0, 0, NULL, 1, 0, 195, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCO', N'01.00', N'Name single IP Connection old', N'IPName', 0, 0, NULL, 1, 0, 195, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NCU', N'01.00', N'Name connection update', N'IPName', 0, 1, N'U', 1, 0, 164, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NPA', N'01.00', N'New patronym add', N'IPName', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTA', N'01.00', N'Nationality add', N'IPNationality', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTD', N'01.00', N'Nationality delete', N'IPNationality', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTN', N'01.00', N'Nationality of an IP new ', N'IPNationality', 0, 0, N'A', 1, 0, 75, 1, N'različne dolžine (!)')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTO', N'01.00', N'Nationality of an IP old', N'IPNationality', 0, 0, NULL, 1, 0, 0, 0, N'različne dolžine (!)')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NTU', N'01.00', N'Nationality update', N'IPNationality', 0, 1, N'U', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUA', N'01.00', N'Name usage add', N'IPNameUsage', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUD', N'01.00', N'Name usage delete', N'IPNameUsage', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUN', N'01.00', N'Name single IP Usage New', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'NUO', N'01.00', N'Name single IP Usage old', N'IPNameUsage', 0, 0, NULL, 1, 0, 34, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'ONN', N'01.00', N'Other name connection new ', N'IPName', 0, 0, NULL, 1, 0, 206, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'ONO', N'01.00', N'Other name connection old', N'IPName', 0, 0, NULL, 1, 0, 206, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REA', N'01.00', N'Remark of society add', NULL, 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'RED', N'01.00', N'Remark delete', NULL, 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REN', N'01.00', N'Remarks of a society new ', NULL, 0, 0, NULL, 1, 0, 57, 0, N'še ne zaznano v uvozu')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'REO', N'01.00', N'Remarks of a society old', NULL, 0, 0, NULL, 1, 0, 57, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STA', N'01.00', N'Status add', N'IPStatus', 0, 1, N'A', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STD', N'01.00', N'Status delete', N'IPStatus', 0, 1, N'D', 1, 0, 110, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STN', N'01.00', N'Status of a new IP', N'IPStatus', 0, 0, NULL, 1, 0, 75, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'STO', N'01.00', N'Status of an IP old', N'IPStatus', 0, 0, NULL, 1, 0, 75, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TMA', N'01.00', N'Territory of a membership agreement', N'IPMembershipTerritory', 0, 0, NULL, 1, 0, 60, 1, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TRL', N'01.00', N'End of header', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[RowCodes] ([RowCode], [Version], [Name], [TargetTable], [IsGroupHeader], [IsHeader], [TransactionType], [IsParserActive], [IsNonData], [Length], [IsTotal], [Note]) VALUES (N'TRS', N'01.00', N'Transaction status', NULL, 1, 0, NULL, 0, 1, 0, 0, N'new')
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (0, N'READY', N'The database is ready. All transactions are committed.', 1)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (1, N'PROCESSING', N'The database is processing. Some tables may get locked.', 0)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (2, N'INTERRUPTED', N'The database processing has been interrupted. Some transactions may be open.', 0)
GO
INSERT [dbo].[State] ([StateCode], [Name], [Description], [IsActive]) VALUES (3, N'MAINTENANCE', N'The database is being maintained. The data may modifiy. Some transactions may be open. Some tables may get locked.', 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (-10, NULL, NULL, N'HeaderUpdate', N'UPDATE', N'BAD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (10, N'IPA', N'IPA', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (20, N'IPA', N'BDN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (30, N'IPA', N'STN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (40, N'IPA', N'NCN,ONN,MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (50, N'IPA', N'MAN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (60, N'IPA', N'TMA', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (70, N'IPA', N'NTN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (80, N'IPA', N'NUN,INN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (90, N'IPA', N'MUN,IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (100, N'MAA', N'MAN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (110, N'MAA', N'TMA', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (120, N'NCA', N'NCN,ONN,MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (130, N'NCA', N'NUN,INN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (140, N'NCA', N'MUN,IMN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (150, N'NPA', N'NCN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (160, N'NPA', N'NCO+NCN', NULL, N'UPDATE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (170, N'NPA', N'NUN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (180, N'NTA', N'NTN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (190, N'NUA', N'NUN,INN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (200, N'NUA', N'MUN,IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (210, N'STA', N'STN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (220, N'BDU', N'BDN', NULL, N'UPDATE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (230, N'NTU', N'NTO', NULL, N'DELETE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (240, N'NTU', N'NTN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (250, N'MAU', N'MAO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (260, N'MAU', N'MAN', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (270, N'MAU', N'TMA', NULL, N'INSERT', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (280, N'NCU', N'NCO+NCN', NULL, N'UPDATE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (290, N'NCU', N'NCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (300, N'NCU', N'NCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (310, N'NCU', N'MCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (311, N'NCU', N'MCN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (320, N'NCU', N'ONO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (321, N'NCU', N'ONN', NULL, N'INSERT', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (330, N'NCU', N'MCO,ONO+NCN', NULL, N'UPDATE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (340, N'NCU', N'IMO', NULL, N'DELETE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (350, N'NCU', N'IMN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (360, N'NCU', N'INO', NULL, N'DELETE', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (370, N'NCU', N'INN', NULL, N'INSERT', N'GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (380, N'MAD', N'MAO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (390, N'NUD', N'INO,NUO,MUO,IMO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (400, N'NCD', N'MCO', NULL, N'DELETE', N'VERY GOOD', NULL, 1)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (410, N'NTD', N'NTO', NULL, N'DELETE', N'VERY GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (420, N'STD', N'STO', NULL, N'DELETE', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionRecordInfo] ([Step], [HeaderCode], [RowCodes], [Name], [Action], [Tuned], [MissingIndex], [IsNameRecord]) VALUES (430, N'STD', N'STN', NULL, N'INSERT', N'GOOD', NULL, 0)
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (-1, N'ROLLED BACK', N'The processing failed. The transaction has been rolled back. The transaction is not active. ')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (0, N'IDLE', N'The transaction is in idle state and is active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (1, N'PROCESSING', N'The transaction is being processed right now. The transaction is active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (2, N'COMMITED', N'The transaction has been successfully commited. The transaction is not active.')
GO
INSERT [dbo].[TransactionStatus] ([Status], [Name], [Description]) VALUES (3, N'INVALID', N'The transaction is invalid. It produces disallowed duplicates. This status means that something got wrong at the data provider. Transaction cannot be processed.')
GO
/****** Object:  Index [ix_DatabaseLog_Timestamp]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_DatabaseLog_Timestamp] ON [dbo].[DatabaseLog]
(
	[Timestamp] ASC
)
INCLUDE ( 	[DatabaseState]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UK_File]    Script Date: 16. 04. 2020 23:22:07 ******/
ALTER TABLE [dbo].[File] ADD  CONSTRAINT [UK_File] UNIQUE NONCLUSTERED 
(
	[File] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Import_01_IsParsed]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Import_01_IsParsed] ON [dbo].[Import]
(
	[IsParsed] ASC
)
INCLUDE ( 	[RowCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Import_02_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Import_02_RowCode] ON [dbo].[Import]
(
	[RowCode] ASC
)
INCLUDE ( 	[RowID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Import_03_RowID]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Import_03_RowID] ON [dbo].[Import]
(
	[RowID] ASC
)
INCLUDE ( 	[RowCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Import_04_RowID]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Import_04_RowID] ON [dbo].[Import]
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Restore_01]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Restore_01] ON [dbo].[Restore]
(
	[CanRestore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Restore_02]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Restore_02] ON [dbo].[Restore]
(
	[ID] ASC,
	[CanRestore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Restore_03]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Restore_03] ON [dbo].[Restore]
(
	[IsProcessing] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_Restore_04]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Restore_04] ON [dbo].[Restore]
(
	[ForProcessing] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Row_01_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Row_01_RowCode] ON [dbo].[Row]
(
	[RowCode] ASC,
	[HeaderID] ASC,
	[RowID] ASC,
	[IPBN] ASC,
	[IPBNNew] ASC,
	[HeaderCode] ASC,
	[IPNN] ASC
)
INCLUDE ( 	[NameType],
	[AmendDate],
	[AmendTime],
	[Name],
	[FirstName],
	[CreationDate],
	[CreationTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Row_02_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Row_02_RowCode] ON [dbo].[Row]
(
	[RowCode] ASC,
	[IPBN] ASC
)
INCLUDE ( 	[HeaderID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Row_03_HeaderID]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Row_03_HeaderID] ON [dbo].[Row]
(
	[HeaderID] ASC,
	[HeaderCode] ASC,
	[RowCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Row_04_IPBN]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Row_04_IPBN] ON [dbo].[Row]
(
	[IPBN] ASC
)
INCLUDE ( 	[RowID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_Row_05_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_Row_05_RowCode] ON [dbo].[Row]
(
	[RowCode] ASC,
	[IPNN] ASC,
	[IPBN] ASC,
	[HeaderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_RowCodes_01_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_RowCodes_01_RowCode] ON [dbo].[RowCodes]
(
	[RowCode] ASC,
	[IsHeader] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_RowHeader_01_HeaderID]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_RowHeader_01_HeaderID] ON [dbo].[RowHeader]
(
	[HeaderID] ASC
)
INCLUDE ( 	[RowID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_RowHeader_02_HeaderCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_RowHeader_02_HeaderCode] ON [dbo].[RowHeader]
(
	[HeaderCode] ASC
)
INCLUDE ( 	[HeaderID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_RowHeader_03_RowCode]    Script Date: 16. 04. 2020 23:22:07 ******/
CREATE NONCLUSTERED INDEX [ix_RowHeader_03_RowCode] ON [dbo].[RowHeader]
(
	[RowID] ASC,
	[RowCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatabaseLog] ADD  CONSTRAINT [DF_DatabaseLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[DatabaseLog] ADD  CONSTRAINT [DF_DatabaseLog_DatabaseState]  DEFAULT ((0)) FOR [DatabaseState]
GO
ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_ImportDate]  DEFAULT (getdate()) FOR [ImportDate]
GO
ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_FirstRowID]  DEFAULT ((0)) FOR [FirstRowID]
GO
ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_LastRowID]  DEFAULT ((0)) FOR [LastRowID]
GO
ALTER TABLE [dbo].[File] ADD  CONSTRAINT [DF_File_IsDiff]  DEFAULT ((1)) FOR [IsDiff]
GO
ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_IsHeaderParsed]  DEFAULT ((0)) FOR [IsHeader]
GO
ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_IsRecordParsed]  DEFAULT ((0)) FOR [IsParsed]
GO
ALTER TABLE [dbo].[Import] ADD  CONSTRAINT [DF_Import_ErrorID]  DEFAULT ((0)) FOR [ErrorID]
GO
ALTER TABLE [dbo].[Interrupted] ADD  CONSTRAINT [DF_Interrupted_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[Log] ADD  CONSTRAINT [DF_Log_DatabaseState]  DEFAULT ((0)) FOR [DatabaseState]
GO
ALTER TABLE [dbo].[Restore] ADD  CONSTRAINT [DF_Restore_IsProcessing]  DEFAULT ((0)) FOR [IsProcessing]
GO
ALTER TABLE [dbo].[Restore] ADD  DEFAULT ((0)) FOR [ForProcessing]
GO
ALTER TABLE [dbo].[RestoreLog] ADD  CONSTRAINT [DF_RestoreLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsFileHeader]  DEFAULT ((0)) FOR [IsGroupHeader]
GO
ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsParserActive]  DEFAULT ((0)) FOR [IsParserActive]
GO
ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsNonData]  DEFAULT ((0)) FOR [IsNonData]
GO
ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_Length]  DEFAULT ((0)) FOR [Length]
GO
ALTER TABLE [dbo].[RowCodes] ADD  CONSTRAINT [DF_RowCodes_IsTotal]  DEFAULT ((0)) FOR [IsTotal]
GO
ALTER TABLE [dbo].[Session] ADD  CONSTRAINT [DF_Session_BeginProcessing]  DEFAULT (getdate()) FOR [BeginTime]
GO
ALTER TABLE [dbo].[Transaction] ADD  CONSTRAINT [DF_Transaction_TransactionStatus]  DEFAULT ((0)) FOR [TransactionStatus]
GO
ALTER TABLE [dbo].[Transaction] ADD  DEFAULT ((0)) FOR [IsReprocess]
GO
ALTER TABLE [dbo].[TransactionRecordInfo] ADD  CONSTRAINT [DF_ProcessingStep_Tuned]  DEFAULT ((0)) FOR [Tuned]
GO
ALTER TABLE [dbo].[TransactionRecordInfo] ADD  CONSTRAINT [DF_TransactionRecordInfo_IsNameRecord]  DEFAULT ((0)) FOR [IsNameRecord]
GO
ALTER TABLE [dbo].[Config]  WITH CHECK ADD  CONSTRAINT [FK_Config_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO
ALTER TABLE [dbo].[Config] CHECK CONSTRAINT [FK_Config_DatabaseState]
GO
ALTER TABLE [dbo].[DatabaseLog]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseLog_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO
ALTER TABLE [dbo].[DatabaseLog] CHECK CONSTRAINT [FK_DatabaseLog_DatabaseState]
GO
ALTER TABLE [dbo].[Interrupted]  WITH CHECK ADD  CONSTRAINT [FK_Interrupted_SID] FOREIGN KEY([SID])
REFERENCES [dbo].[Session] ([SID])
GO
ALTER TABLE [dbo].[Interrupted] CHECK CONSTRAINT [FK_Interrupted_SID]
GO
ALTER TABLE [dbo].[Log]  WITH CHECK ADD  CONSTRAINT [FK_Log_DatabaseState] FOREIGN KEY([DatabaseState])
REFERENCES [dbo].[State] ([StateCode])
GO
ALTER TABLE [dbo].[Log] CHECK CONSTRAINT [FK_Log_DatabaseState]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_HeaderCode] FOREIGN KEY([HeaderCode])
REFERENCES [dbo].[RowCodes] ([RowCode])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_HeaderCode]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_SID] FOREIGN KEY([SID])
REFERENCES [dbo].[Session] ([SID])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_SID]
GO
ALTER TABLE [dbo].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_TransactionStatus] FOREIGN KEY([TransactionStatus])
REFERENCES [dbo].[TransactionStatus] ([Status])
GO
ALTER TABLE [dbo].[Transaction] CHECK CONSTRAINT [FK_Transaction_TransactionStatus]
GO
ALTER TABLE [dbo].[TransactionRecordInfo]  WITH CHECK ADD  CONSTRAINT [FK_ProcessingStep_HeaderCode] FOREIGN KEY([HeaderCode])
REFERENCES [dbo].[RowCodes] ([RowCode])
GO
ALTER TABLE [dbo].[TransactionRecordInfo] CHECK CONSTRAINT [FK_ProcessingStep_HeaderCode]
GO
ALTER TABLE [ipi].[IPMembership]  WITH CHECK ADD  CONSTRAINT [FK_IPMembership_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO
ALTER TABLE [ipi].[IPMembership] CHECK CONSTRAINT [FK_IPMembership_ID]
GO
ALTER TABLE [ipi].[IPMembershipTerritory]  WITH CHECK ADD  CONSTRAINT [FK_IPMembershipTerritory_MID] FOREIGN KEY([MID])
REFERENCES [ipi].[IPMembership] ([MID])
ON DELETE CASCADE
GO
ALTER TABLE [ipi].[IPMembershipTerritory] CHECK CONSTRAINT [FK_IPMembershipTerritory_MID]
GO
ALTER TABLE [ipi].[IPName]  WITH CHECK ADD  CONSTRAINT [FK_IPName_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO
ALTER TABLE [ipi].[IPName] CHECK CONSTRAINT [FK_IPName_ID]
GO
ALTER TABLE [ipi].[IPNameUsage]  WITH CHECK ADD  CONSTRAINT [FK_IPNameUsage_NID] FOREIGN KEY([NID])
REFERENCES [ipi].[IPName] ([NID])
ON DELETE CASCADE
GO
ALTER TABLE [ipi].[IPNameUsage] CHECK CONSTRAINT [FK_IPNameUsage_NID]
GO
ALTER TABLE [ipi].[IPNationality]  WITH CHECK ADD  CONSTRAINT [FK_IPNationality_ID] FOREIGN KEY([ID])
REFERENCES [ipi].[IP] ([ID])
GO
ALTER TABLE [ipi].[IPNationality] CHECK CONSTRAINT [FK_IPNationality_ID]
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
/****** Object:  StoredProcedure [dbo].[CheckCollation]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.CheckCollation
Description:	Checks if this database and tempdb has the same collation.
				If not, then the collation conflicts in the procedure dbo.Query_270 will occur.
				(Check the procedure for more info.)
*/

CREATE PROCEDURE [dbo].[CheckCollation]
AS 

DECLARE @db_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX(DB_NAME(),'collation')));
DECLARE @tempdb_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX('tempdb','collation')));

IF @db_collation <> @tempdb_collation
BEGIN
	PRINT 'WARNING: The collations of this database and tempdb differ. 
         Please check the stored procedures dbo.Query_270 and 
		 follow the instructions in the header of the procedure.';
END;

GO
/****** Object:  StoredProcedure [dbo].[CheckDatabase]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.CheckDatabase
Description:	Checks if database is correctly initialized.
*/

CREATE PROCEDURE [dbo].[CheckDatabase]
AS 

BEGIN TRY

-- check dbo.Config
IF 1 <> (SELECT COUNT(*) FROM dbo.Config)
BEGIN
	RAISERROR('Database is not correctly initialized: The configuration table dbo.Config is empty.', 16, 1);
END;

-- check dbo.File
IF 0 = (SELECT COUNT(*) FROM dbo.[File])
BEGIN
	RAISERROR('Database is not correctly initialized: The file table is empty.', 16, 1);
END;

-- check collation
DECLARE @db_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX(DB_NAME(),'collation')));
DECLARE @tempdb_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX('tempdb','collation')));

IF @db_collation <> @tempdb_collation
BEGIN
	PRINT 'WARNING: The collations of this database and tempdb differ. 
         Please check the stored procedures dbo.Query_270 and 
		 follow the instructions in the header of the procedure.';
END;

END TRY
BEGIN CATCH
	THROW;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[ClearImport]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.ClearImport
Description:		Clears dbo.Import table and prepare its RowID identifier for next import.
*/

CREATE PROCEDURE [dbo].[ClearImport]
AS

SET NOCOUNT ON;

-- clear
TRUNCATE TABLE dbo.Import;

-- set seed
DECLARE @LastRowID AS bigint;
SET @LastRowID = ISNULL((SELECT MAX(LastRowID) + 1 FROM dbo.[File]), 1);
DBCC CHECKIDENT ('dbo.Import', reseed, @LastRowID);

EXEC dbo.FastPrint '-----------------------------------------------';
EXEC dbo.FastPrint 'Import table has been cleared and reseeded.';

DECLARE @msg AS nvarchar(100) = 'Next RowID set to: ' + CAST(@LastRowID AS nvarchar(20));
EXEC dbo.FastPrint @msg;
EXEC dbo.FastPrint '-----------------------------------------------';

GO
/****** Object:  StoredProcedure [dbo].[ClearSession]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.ClearSession
Description:	Clears the global session variable.
*/

CREATE PROCEDURE [dbo].[ClearSession]
AS 

-- reset in-memory SID
EXEC [dbo].[SetContextData] 0;


GO
/****** Object:  StoredProcedure [dbo].[CloseSession]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.CloseSession
Description:	Closes the open session.
*/

CREATE PROCEDURE [dbo].[CloseSession]
AS 

-- get active session
DECLARE @SID AS int = dbo.GetSID();

-- close only valid session
IF dbo.IsSessionValid() = 1
BEGIN

	-- update session's EndTime
	UPDATE dbo.[Session]
	SET EndTime = GETDATE()
	WHERE [SID] = @SID;

END;

-- reset in-memory SID
EXEC [dbo].[SetContextData] 0;





GO
/****** Object:  StoredProcedure [dbo].[Controller]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.Controller
Description:		Controls the progression of the import based on the existance of the next consecutive file.

Returns:			0 : Next file is found.
					1 : Import is not needed (any more).
				   -1 : FILE NOT FOUND. Import should be aborted.
*/

CREATE PROCEDURE [dbo].[Controller]
	@NextFile nvarchar(128) OUTPUT
AS

SET NOCOUNT ON;

DECLARE @msg AS nvarchar(MAX);

-- compute next file
SET @NextFile = dbo.ComputeNextFile();

-- if NULL return 1 (import not needed)
IF @NextFile IS NULL
BEGIN
	SET @msg = 'Database is up-to-date.';
	EXEC dbo.FastPrint @msg;
	RETURN 1;
END;

-- compose the full path
DECLARE @Path AS nvarchar(100) = (SELECT DiffPath FROM dbo.Config) + @NextFile;

-- check if file exists in the target directory 
IF [dbo].[FileExists](@Path) = 0
BEGIN
	RETURN -1;	-- FILE NOT FOUND
END;

-- Next consecutive file exists
RETURN 0;


GO
/****** Object:  StoredProcedure [dbo].[FastPrint]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.FastPrint
Description:	Send message to output immediately (without waiting the execution to finish).
Author:			Miha Grobovšek
*/

CREATE PROCEDURE [dbo].[FastPrint]
	@text nvarchar(MAX) 
AS
BEGIN
	RAISERROR(@text,0,0) WITH NOWAIT;
END;

GO
/****** Object:  StoredProcedure [dbo].[Finalize]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Finalize
Description:	Finalize the processing with setting the database state as READY.
Note:			This procedure is called AT THE END of the dbo.ProcessTrans processing.
				---------------------------
				Here the OK log is written.
				---------------------------
*/

CREATE PROCEDURE [dbo].[Finalize]
AS

SET NOCOUNT ON;

-- Sets the database state as READY.
--UPDATE dbo.[Config] SET [DatabaseState] = 0;
EXEC dbo.SetReady;

-- Output to console.
EXEC dbo.FastPrint '=============================================================';
EXEC dbo.FastPrint 'THE PROCESSING COMPLETED. DATABASE IS IN READY STATE.';
EXEC dbo.FastPrint '=============================================================';

-- Write log.
EXEC dbo.WriteLog 1, 'OK', NULL, 0;



GO
/****** Object:  StoredProcedure [dbo].[FinalizeRestore]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Object:			dbo.FinalizeRestore
Description:	Finalize restore by updating counters and restore statuses.
Note:			This procedure should be run manually if the restore procedure
				has been interrupted.		 
*/

CREATE PROCEDURE [dbo].[FinalizeRestore]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint 'Finalize restore...';

IF 0 = (
	SELECT COUNT(*) FROM dbo.[Restore] 
	WHERE ForProcessing = 1 AND CanRestore = 0
)
BEGIN
	EXEC dbo.FastPrint 'No data to count. Finalizer terminated.';
	RETURN;
END;

CREATE TABLE #MEMBERSHIP (
	MID bigint NOT NULL PRIMARY KEY,
	ID int NOT NULL
);

INSERT INTO #MEMBERSHIP (MID, ID)
SELECT A.MID, A.ID 
FROM [ipi].[IPMembership] AS A
INNER JOIN dbo.[Restore] AS C ON A.ID = C.ID
WHERE C.ForProcessing = 1 AND C.CanRestore = 0;

CREATE NONCLUSTERED INDEX ix_#MEMBERSHIP ON #MEMBERSHIP (MID);

-- update new membership counters
UPDATE X
SET X.[MembershipNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #MEMBERSHIP AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

CREATE TABLE #TERRITORY (
	ID int NOT NULL
);

EXEC dbo.FastPrint 'Membership counters updated.';

INSERT INTO #TERRITORY
SELECT A.ID 
FROM #MEMBERSHIP AS A
INNER JOIN [ipi].[IPMembershipTerritory] AS B ON A.MID = B.MID;

CREATE NONCLUSTERED INDEX ix_#TERRITORY ON #TERRITORY (ID);

-- update new territory counters
UPDATE X
SET X.[MembershipTerritoryNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #TERRITORY AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

EXEC dbo.FastPrint 'Territory counters updated.';

-- Update processing status
UPDATE [dbo].[Restore]
SET ForProcessing = 0
WHERE ForProcessing = 1 
	AND CanRestore = 0;

UPDATE [dbo].[Restore]
SET IsProcessing = 0
WHERE IsProcessing = 1;

EXEC dbo.FastPrint 'Statuses updated.';
EXEC dbo.FastPrint '-------------------------';
EXEC dbo.FastPrint 'Restore terminated.';

GO
/****** Object:  StoredProcedure [dbo].[ImportDiff]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.ImportDiff
Description:		Imports all missing CONSECUTIVE differential files from the last import until today.
					-------------------------------------------------------------------------------------------------
Logic:				1. Loop while the procedure [dbo].[ImportFileDiff] returns 0 => IMPORT IS COMPLETED
					2. Terminate if next file does not exist:
					3. If RETURN VALUE = 1 => import was not needed (all files till today have already been imported)
					4. If RETURN VALUE = -1 => next file should exist, but does not exists.		
					-------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[ImportDiff]
AS

SET NOCOUNT ON;

DECLARE @ImportResult AS int = 0; 

BEGIN TRY;

	-- loop through all consecutive files
	WHILE @ImportResult = 0
	BEGIN

		EXEC @ImportResult = dbo.ImportFileDiff;

	END;

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Pri uvozu je prišlo do napake.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;



GO
/****** Object:  StoredProcedure [dbo].[ImportFileDiff]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.ImportFileDiff
Description:		Imports differential (day) files using BULK INSERT.
					-------------------------------------------------------------------------------
Note:				All CONSECUTIVE files in the IMPORT DIRECTORY are to be imported in SQL Server.
					-------------------------------------------------------------------------------
Return:				0 : Import completed with success.
					1 : Import was not needed.
				   -1 : FILE NOT FOUND. Import aborted.
*/

CREATE PROCEDURE [dbo].[ImportFileDiff]
AS

SET NOCOUNT ON;

DECLARE @ControllerResult AS int;
DECLARE @msg AS nvarchar(MAX);
DECLARE @NextFile AS nvarchar(128);
DECLARE @MinRowID AS bigint = ISNULL(
	(SELECT MAX(RowID) + 1 FROM dbo.Import), 
	(SELECT LastRowID + 1 FROM dbo.LastFile));

BEGIN TRY;

	-- get next file from the Controller & check return value
	EXEC @ControllerResult = dbo.Controller @NextFile OUTPUT;
	IF @ControllerResult != 0
	BEGIN
		RETURN @ControllerResult;	-- forward the Controller's return value
	END;

	-- compose the full path
	DECLARE @Path AS nvarchar(100) = (SELECT DiffPath FROM dbo.Config) + @NextFile;

	-- build SQL & exec
	DECLARE @sql AS nvarchar(MAX);
	SET @sql =
		N'BULK INSERT dbo.ToImport ' +
		N'FROM ''' + @Path + ''' ' +
		N'WITH ' + 
		N'( ' +
		N'KEEPIDENTITY, ' +
		N'ROWTERMINATOR = ''\n'' ' +
		N');';
	EXEC(@sql);

	SET @msg = 'File ' + @NextFile + ': import finished.';
	EXEC dbo.FastPrint @msg;

	-- get SID
	DECLARE @SID AS int = dbo.GetSID();

	DECLARE @FileID AS int;
	INSERT INTO dbo.[File] ([File], [SID])
	VALUES (@NextFile, @SID);

	SET @FileID = SCOPE_IDENTITY();

	-- set FileID to newly imported rows
	UPDATE dbo.Import
	SET FileID = @FileID
	WHERE FileID IS NULL;

	-- update RowID interval
	UPDATE dbo.[File] 
	SET 
		FirstRowID = @MinRowID
		, LastRowID = (SELECT MAX(RowID) FROM dbo.Import)
	WHERE FileID = @FileID;

	-- Import completed with success;
	RETURN 0;

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Pri diferenčnem uvozu je prišlo do napake.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	EXEC dbo.FastPrint '-----------------------------------------------';
	RETURN -2;

END CATCH;



GO
/****** Object:  StoredProcedure [dbo].[Initialize]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Initialize
Description:	Puts the database into PROCESSING state, clears the dbo.Import table, and reseeds RowID.
Note:			This procedure is called AT THE BEGINNING of the dbo.ProcessDiff processing.
*/

CREATE PROCEDURE [dbo].[Initialize]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint '=============================================================';
EXEC dbo.FastPrint 'THE PROCESSING STARTED. DATABASE IS IN PROCESSING STATE.';
EXEC dbo.FastPrint '=============================================================';

-- set database state to PROCESSING
UPDATE dbo.[Config] SET [DatabaseState] = 1;

-- clear & reseed import table
EXEC [dbo].[ClearImport];



GO
/****** Object:  StoredProcedure [dbo].[InitializeDatabase]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.InitializeDatabase
Description:	Initialize the database by cleaning the target tables and preparing
				the configuration.
*/

CREATE PROCEDURE [dbo].[InitializeDatabase]
	@ImportDirectory varchar(128),	-- import directory with *.IPI files to import 
	@FirstFileName char(12)			-- name of the first IPI file to import
AS

SET NOCOUNT ON;

BEGIN TRY

-- Get path 
SET @ImportDirectory = IIF(SUBSTRING(@ImportDirectory, LEN(@ImportDirectory), 1) <> '\', 
	@ImportDirectory + '\', @ImportDirectory);
DECLARE @Path nvarchar(128) = @ImportDirectory + @FirstFileName;

---------------------------------------------------------------
-- Check if file exists
---------------------------------------------------------------

-- Check if @FirstFileName exists:
DECLARE @FileExists bit = [dbo].[FileExists](@Path);
IF @FileExists <> 1
BEGIN
	RAISERROR('File does not exist.', 16, 1);
END;

---------------------------------------------------------------
-- Check if file has correct name format
---------------------------------------------------------------

-- check length
IF LEN(@FirstFileName) <> 12
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

-- check date format
IF ISDATE(SUBSTRING(@FirstFileName, 1, 8)) = 0
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

-- check file extension
IF SUBSTRING(@FirstFileName, 10, 3) <> 'IPI'
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

---------------------------------------------------------------
-- Clear tables
---------------------------------------------------------------

TRUNCATE TABLE [dbo].[Config];
TRUNCATE TABLE [dbo].[DatabaseLog];
TRUNCATE TABLE [dbo].[File];
TRUNCATE TABLE [dbo].[Import];
TRUNCATE TABLE [dbo].[Interrupted]; 
TRUNCATE TABLE [dbo].[Log];
TRUNCATE TABLE [dbo].[Row]; 
TRUNCATE TABLE [dbo].[RowHeader];
TRUNCATE TABLE [dbo].[Transaction];
DELETE FROM [dbo].[Session]; DBCC CHECKIDENT ('dbo.Session', reseed, 1);

TRUNCATE TABLE [ipi].[IPMembershipTerritory];
TRUNCATE TABLE [ipi].[IPNameUsage];
TRUNCATE TABLE [ipi].[IPNationality];
TRUNCATE TABLE [ipi].[IPStatus];
DELETE FROM [ipi].[IPName]; DBCC CHECKIDENT ('ipi.IPName', reseed, 1);
DELETE FROM [ipi].[IPMembership]; DBCC CHECKIDENT ('ipi.IPMembership', reseed, 1);
DELETE FROM [ipi].[IP]; DBCC CHECKIDENT ('ipi.IP', reseed, 1);

---------------------------------------------------------------
-- Initialize dbo.File and dbo.Config tables
---------------------------------------------------------------

DECLARE @PrevDate char(8) = 
	REPLACE(CONVERT(char(10), DATEADD(DAY, -1, SUBSTRING(@FirstFileName, 1, 8)), 127), '-', '');
DECLARE @PrevFile char(12) = CONCAT(@PrevDate, '.IPI');

INSERT INTO [dbo].[File]
([File], ImportDate, FirstRowID, LastRowID, IsDiff, Note)
VALUES (@PrevFile, GETDATE(), 0, 0, 0, 'Initial row to set RefDate');

INSERT INTO [dbo].[Config]
(DiffPath, DatabaseState, LastCommitedHeaderID)
VALUES (@ImportDirectory, 0, 0);

---------------------------------------------------------------
-- Check if db-tempdb collation matches
---------------------------------------------------------------

EXEC [dbo].[CheckCollation];

---------------------------------------------------------------

EXEC [dbo].[WriteLog] 1, 'The database is initialized.', NULL, 0;

PRINT '-------------------------------------------------';
PRINT 'Database initialization completed.';

END TRY
BEGIN CATCH

	-- Initialization failed:
	PRINT 'Database initialization failed. Please pass correct parameters and try again.';
	THROW;

END CATCH;
GO
/****** Object:  StoredProcedure [dbo].[InitializeRestore]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.InitializeRestore
Description:	Initialize restore by updating current membership counters.		 
*/

CREATE PROCEDURE [dbo].[InitializeRestore]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint 'Initialize restore...';

IF 0 = (
	SELECT COUNT(*) FROM dbo.[Restore] 
	WHERE ForProcessing = 1
)
BEGIN
	EXEC dbo.FastPrint 'No data to count. Initializer terminated.';
	RETURN;
END;

CREATE TABLE #MEMBERSHIP (
	MID bigint NOT NULL PRIMARY KEY,
	ID int NOT NULL
);

INSERT INTO #MEMBERSHIP (MID, ID)
SELECT A.MID, A.ID 
FROM [ipi].[IPMembership] AS A
INNER JOIN dbo.[Restore] AS C ON A.ID = C.ID
WHERE C.ForProcessing = 1;

CREATE NONCLUSTERED INDEX ix_#MEMBERSHIP ON #MEMBERSHIP (MID);

-- update new membership counters
UPDATE X
SET X.[MembershipOldCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #MEMBERSHIP AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

CREATE TABLE #TERRITORY (
	ID int NOT NULL
);

EXEC dbo.FastPrint 'Membership counters updated.';

INSERT INTO #TERRITORY
SELECT A.ID 
FROM #MEMBERSHIP AS A
INNER JOIN [ipi].[IPMembershipTerritory] AS B ON A.MID = B.MID;

CREATE NONCLUSTERED INDEX ix_#TERRITORY ON #TERRITORY (ID);

-- update new territory counters
UPDATE X
SET X.[MembershipTerritoryOldCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #TERRITORY AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

EXEC dbo.FastPrint 'Territory counters updated.';
EXEC dbo.FastPrint 'Restore initialization finished.';
GO
/****** Object:  StoredProcedure [dbo].[Iterator]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Iterator
Description:	Iterates through all active parsers and parse body data of all non-parsed rows.
*/

CREATE PROCEDURE [dbo].[Iterator]
AS

BEGIN TRY;

	EXEC dbo.FastPrint '-------------------------------------------';
	EXEC dbo.FastPrint 'Parsing started...';

	DECLARE @RowCode AS char(3); 
	DECLARE @Version AS char(5); 
	DECLARE @sql AS nvarchar(1000);
	DECLARE CURSOR1 CURSOR LOCAL FAST_FORWARD 
	FOR
	  SELECT RowCode, [Version] FROM dbo.RowCodes
	  WHERE IsParserActive = 1
	OPEN CURSOR1;
	FETCH NEXT FROM CURSOR1 INTO @RowCode, @Version;
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @sql = N'EXEC dbo.Parse_' + @RowCode + ' ''' + @Version + '''';
		EXEC sp_executesql @sql;
	  FETCH NEXT FROM CURSOR1 INTO @RowCode, @Version;
	END; 
	CLOSE CURSOR1; 
	DEALLOCATE CURSOR1;

END TRY
BEGIN CATCH

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;



GO
/****** Object:  StoredProcedure [dbo].[Parse]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse
Description:	Parses all non-parsed header rows.
*/

CREATE PROCEDURE [dbo].[Parse]
AS

SET NOCOUNT ON;

BEGIN TRY;

DECLARE @msg AS nvarchar(MAX);

EXEC dbo.FastPrint '-------------------------------------------';

------------------------------------------------------------------------------------
-- Parse 3-char RowCode.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET RowCode = SUBSTRING(Row, 1, 3)
WHERE IsParsed = 0;

EXEC dbo.FastPrint 'RowCodes have been parsed.';

------------------------------------------------------------------------------------
-- File content validation (by parsing the RowCodes).
-- Note: IF A FILE CONTENT IS NOT VALID IT IS VERY LIKELY
-- THAT ROW CODE WILL NOT GET PARSED CORRECTLY.
------------------------------------------------------------------------------------

IF EXISTS (
	SELECT NULL
	FROM dbo.Import AS A
	LEFT OUTER JOIN [dbo].[RowCodes] AS B ON A.RowCode = B.RowCode
	WHERE B.RowCode IS NULL
)
BEGIN
	EXEC dbo.FastPrint 'Invalid file content. RowCode does not exist.';
	RAISERROR('Invalid file content. RowCode does not exist.', 16, 1);
END;

------------------------------------------------------------------------------------
-- Header validation.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET ErrorID = 1
WHERE RowCode = 'GRH'
	AND IsParsed = 0
	AND LEN(Row) != 16;

IF @@ROWCOUNT = 0
BEGIN
	EXEC dbo.FastPrint 'Import header is valid.';
END
ELSE BEGIN
	EXEC dbo.FastPrint 'Invalid import header (GRH).';
	RAISERROR('Invalid import header (GRH).', 16, 1);
END;

------------------------------------------------------------------------------------
-- Set header parse status.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET IsParsed = 1
WHERE RowCode = 'GRH'
	AND IsParsed = 0
	AND ErrorID = 0;

------------------------------------------------------------------------------------
-- Iterate & parse.
------------------------------------------------------------------------------------

EXEC dbo.Iterator;

EXEC dbo.FastPrint 'Parsing completed.';

------------------------------------------------------------------------------------
-- Check if all imported rows have been parsed.
------------------------------------------------------------------------------------

DECLARE @UnparsedRowCode AS char(3);
SELECT TOP(1) @UnparsedRowCode = RowCode FROM [dbo].[UnparsedRowCodes];
IF @UnparsedRowCode IS NOT NULL
BEGIN
	SET @msg = 'ATTENTION: Not all rows have been parsed (' + @UnparsedRowCode + ').';
	EXEC dbo.FastPrint @msg;
	RAISERROR(@msg, 16, 1);
END;

------------------------------------------------------------------------------------
-- Clear & fill row header temp table
-- Note: we use dbo.RowHeader table instead of dbo.Import becuase of its small size.
-------------------------------------------------------------------------------------

TRUNCATE TABLE [dbo].[RowHeader];

INSERT INTO [dbo].[RowHeader]
(RowID, RowCode)
SELECT RowID, RowCode
FROM dbo.Import;

------------------------------------------------------------------------------------
-- Process header (time consuming operation).
------------------------------------------------------------------------------------

EXEC [dbo].[ProcessHeader];

------------------------------------------------------------------------------------
-- The ONLY update on table dbo.Row.
------------------------------------------------------------------------------------

UPDATE X
SET 
	HeaderCode = A.HeaderCode,
	HeaderID = A.HeaderID
FROM dbo.[Row] AS X

-- since RowHeader table contains only diff data
-- this join will exclude all already-processed rows
-- (keeping only newly imported rows for update)
INNER JOIN dbo.RowHeader AS A ON X.RowID = A.RowID;

EXEC dbo.FastPrint 'Header in dbo.Row table (dbo.Row) UPDATED.';

------------------------------------------------------------------------------------
-- Add new transactions.
------------------------------------------------------------------------------------

DECLARE @SID AS int = dbo.GetSID();

INSERT INTO [dbo].[Transaction]
([SID], HeaderCode, HeaderID)
SELECT DISTINCT @SID, HeaderCode, HeaderID
FROM [dbo].[RowHeader]
WHERE HeaderCode IS NOT NULL;

SET @msg = 'New transactions have been added (' + CAST(@@ROWCOUNT AS nvarchar(10)) + ').';
EXEC dbo.FastPrint @msg;

------------------------------------------------------------------------------------
-- Add new row codes. (Not likely.)
------------------------------------------------------------------------------------

WITH _Codes AS
(
	SELECT DISTINCT RowCode FROM dbo.Import
)
INSERT INTO dbo.RowCodes (RowCode, Note)
SELECT RowCode, 'new'
FROM _Codes AS A
WHERE NOT EXISTS (
	SELECT AA.RowCode 
	FROM dbo.RowCodes AS AA
	WHERE AA.RowCode = A.RowCode
);

IF @@ROWCOUNT > 0
BEGIN
	EXEC dbo.FastPrint 'New ROW CODES has been added.';
END;

EXEC dbo.FastPrint '-------------------------------------------';
EXEC dbo.FastPrint 'Imported data has been successfully parsed.';

-----------

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Parsing has failed.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Parse_BDN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_BDN
Description:	Parses all non-parsed BDN rows.
*/

CREATE PROCEDURE [dbo].[Parse_BDN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'BDN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, [Type]
	, BirthDate, DeathDate, BirthPlace, BirthState
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, Sex, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 1)
	, SUBSTRING(Row, 21, 8)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 30)
	, SUBSTRING(Row, 67, 30)
	, SUBSTRING(Row, 97, 4)
	, SUBSTRING(Row, 101, 8)
	, SUBSTRING(Row, 109, 20)
	, SUBSTRING(Row, 129, 8)
	, SUBSTRING(Row, 137, 1)
	, SUBSTRING(Row, 138, 8)
	, SUBSTRING(Row, 146, 6)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;

GO
/****** Object:  StoredProcedure [dbo].[Parse_BDO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_BDO
Description:	Parses all non-parsed BDO rows.
*/

CREATE PROCEDURE [dbo].[Parse_BDO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'BDO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, [Type]
	, BirthDate, DeathDate, BirthPlace, BirthState
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, Sex, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 1)
	, SUBSTRING(Row, 21, 8)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 30)
	, SUBSTRING(Row, 67, 30)
	, SUBSTRING(Row, 97, 4)
	, SUBSTRING(Row, 101, 8)
	, SUBSTRING(Row, 109, 20)
	, SUBSTRING(Row, 129, 8)
	, SUBSTRING(Row, 137, 1)
	, SUBSTRING(Row, 138, 8)
	, SUBSTRING(Row, 146, 6)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_BDU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_BDU
Description:	Parses all non-parsed BDU rows.
*/

CREATE PROCEDURE [dbo].[Parse_BDU]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'BDU';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_IMN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_IMN
Description:	Parses all non-parsed IMN rows.
*/

CREATE PROCEDURE [dbo].[Parse_IMN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'IMN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
	, SUBSTRING(Row, 35, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_IMO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_IMO
Description:	Parses all non-parsed IMO rows.
*/

CREATE PROCEDURE [dbo].[Parse_IMO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'IMO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
	, SUBSTRING(Row, 35, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_INN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_INN
Description:	Parses all non-parsed INN rows.
*/

CREATE PROCEDURE [dbo].[Parse_INN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'INN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_INO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_INO
Description:	Parses all non-parsed INO rows.
*/

CREATE PROCEDURE [dbo].[Parse_INO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'INO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_IPA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_IPA
Description:	Parses all non-parsed IPA rows.
*/

CREATE PROCEDURE [dbo].[Parse_IPA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'IPA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode 
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MAA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MAA
Description:	Parses all non-parsed MAA rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MAD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MAD
Description:	Parses all non-parsed MAD rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAD]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAD';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MAN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MAN
Description:	Parses all non-parsed MAN rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, SocietyCode
	, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime
	, ValidToDate, ValidToTime, SignDate, MemberShare, AmendDate
	, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 3)
	, SUBSTRING(Row, 23, 2)
	, SUBSTRING(Row, 25, 2)
	, SUBSTRING(Row, 27, 2)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 6)
	, SUBSTRING(Row, 43, 8)
	, SUBSTRING(Row, 51, 6)
	, SUBSTRING(Row, 57, 8)
	, SUBSTRING(Row, 65, 5)
	, SUBSTRING(Row, 70, 8)
	, SUBSTRING(Row, 78, 6)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MAO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MAO
Description:	Parses all non-parsed MAO rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, SocietyCode
	, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime
	, ValidToDate, ValidToTime, SignDate, MemberShare, AmendDate
	, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 3)
	, SUBSTRING(Row, 23, 2)
	, SUBSTRING(Row, 25, 2)
	, SUBSTRING(Row, 27, 2)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 6)
	, SUBSTRING(Row, 43, 8)
	, SUBSTRING(Row, 51, 6)
	, SUBSTRING(Row, 57, 8)
	, SUBSTRING(Row, 65, 5)
	, SUBSTRING(Row, 70, 8)
	, SUBSTRING(Row, 78, 6)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MAU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MAU
Description:	Parses all non-parsed MAU rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAU]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAU';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MCN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MCN
Description:	Parses all non-parsed MCN rows.
*/

CREATE PROCEDURE [dbo].[Parse_MCN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MCN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 2)
	, SUBSTRING(Row, 123, 8)
	, SUBSTRING(Row, 131, 6)
	, SUBSTRING(Row, 137, 8)
	, SUBSTRING(Row, 145, 6)
	, SUBSTRING(Row, 151, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MCO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MCO
Description:	Parses all non-parsed MCO rows.
*/

CREATE PROCEDURE [dbo].[Parse_MCO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MCO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 2)
	, SUBSTRING(Row, 123, 8)
	, SUBSTRING(Row, 131, 6)
	, SUBSTRING(Row, 137, 8)
	, SUBSTRING(Row, 145, 6)
	, SUBSTRING(Row, 151, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MUN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MUN
Description:	Parses all non-parsed MUN rows.
*/

CREATE PROCEDURE [dbo].[Parse_MUN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MUN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
	, SUBSTRING(Row, 35, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_MUO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_MUO
Description:	Parses all non-parsed MUO rows.
*/

CREATE PROCEDURE [dbo].[Parse_MUO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MUO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
	, SUBSTRING(Row, 35, 13)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NCA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NCA
Description:	Parses all non-parsed NCA rows.
*/

CREATE PROCEDURE [dbo].[Parse_NCA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NCA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NCD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NCD
Description:	Parses all non-parsed NCD rows.
*/

CREATE PROCEDURE [dbo].[Parse_NCD]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NCD';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NCN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NCN
Description:	Parses all non-parsed NCN rows.
*/

CREATE PROCEDURE [dbo].[Parse_NCN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NCN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, FirstName, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 45)
	, SUBSTRING(Row, 166, 2)
	, SUBSTRING(Row, 168, 8)
	, SUBSTRING(Row, 176, 6)
	, SUBSTRING(Row, 182, 8)
	, SUBSTRING(Row, 190, 6)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NCO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NCO
Description:	Parses all non-parsed NCO rows.
*/

CREATE PROCEDURE [dbo].[Parse_NCO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NCO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, FirstName, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 45)
	, SUBSTRING(Row, 166, 2)
	, SUBSTRING(Row, 168, 8)
	, SUBSTRING(Row, 176, 6)
	, SUBSTRING(Row, 182, 8)
	, SUBSTRING(Row, 190, 6)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NCU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NCU
Description:	Parses all non-parsed NCU rows.
*/

CREATE PROCEDURE [dbo].[Parse_NCU]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NCU';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName
	, IPBN, StatusCode, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef, NameTypeRef
	, IPBNNew, StatusCodeNew, IPNNNew, NameTypeNew, IPBNRefNew, StatusCodeRefNew, IPNNRefNew, NameTypeRefNew)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	-- old
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
	-- new 
	, SUBSTRING(Row, 111, 13)
	, SUBSTRING(Row, 124, 1)
	, SUBSTRING(Row, 125, 11)
	, SUBSTRING(Row, 136, 2)
	, SUBSTRING(Row, 138, 13)
	, SUBSTRING(Row, 151, 1)
	, SUBSTRING(Row, 152, 11)
	, SUBSTRING(Row, 163, 2)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NPA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NPA
Description:	Parses all non-parsed NPA rows.
*/

CREATE PROCEDURE [dbo].[Parse_NPA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NPA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NTA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NTA
Description:	Parses all non-parsed NTA rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NTD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NTD
Description:	Parses all non-parsed NTD rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTD]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTD';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NTN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NTN
Description:	Parses all non-parsed NTN rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, ValidFromDate, ValidToDate)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 4)
	, SUBSTRING(Row, 24, 8)
	, SUBSTRING(Row, 32, 20)
	, SUBSTRING(Row, 52, 8)
	, SUBSTRING(Row, 60, 8)
	, SUBSTRING(Row, 68, 8)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NTO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NTO
Description:	Parses all non-parsed NTO rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, ValidFromDate, ValidToDate)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 4)
	, SUBSTRING(Row, 24, 8)
	, SUBSTRING(Row, 32, 20)
	, SUBSTRING(Row, 52, 8)
	, SUBSTRING(Row, 60, 8)
	, SUBSTRING(Row, 68, 8)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NTU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NTU
Description:	Parses all non-parsed NTU rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTU]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTU';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NUA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NUA
Description:	Parses all non-parsed NUA rows.
*/

CREATE PROCEDURE [dbo].[Parse_NUA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NUA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NUD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NUD
Description:	Parses all non-parsed NUD rows.
*/

CREATE PROCEDURE [dbo].[Parse_NUD]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NUD';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NUN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NUN
Description:	Parses all non-parsed NUN rows.
*/

CREATE PROCEDURE [dbo].[Parse_NUN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NUN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_NUO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_NUO
Description:	Parses all non-parsed NUO rows.
*/

CREATE PROCEDURE [dbo].[Parse_NUO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NUO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_ONN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_ONN
Description:	Parses all non-parsed ONN rows.
*/

CREATE PROCEDURE [dbo].[Parse_ONN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'ONN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, FirstName, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPNNRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 45)
	, SUBSTRING(Row, 166, 2)
	, SUBSTRING(Row, 168, 8)
	, SUBSTRING(Row, 176, 6)
	, SUBSTRING(Row, 182, 8)
	, SUBSTRING(Row, 190, 6)
	, SUBSTRING(Row, 196, 11)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_ONO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_ONO
Description:	Parses all non-parsed ONO rows.
*/

CREATE PROCEDURE [dbo].[Parse_ONO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'ONO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, FirstName, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPNNRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 45)
	, SUBSTRING(Row, 166, 2)
	, SUBSTRING(Row, 168, 8)
	, SUBSTRING(Row, 176, 6)
	, SUBSTRING(Row, 182, 8)
	, SUBSTRING(Row, 190, 6)
	, SUBSTRING(Row, 196, 11)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_REA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_REA
Description:	Parses all non-parsed REA rows.
*/

CREATE PROCEDURE [dbo].[Parse_REA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'REA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_RED]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_RED
Description:	Parses all non-parsed RED rows.
*/

CREATE PROCEDURE [dbo].[Parse_RED]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'RED';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_REN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_REN
Description:	Parses all non-parsed REN rows.
*/

CREATE PROCEDURE [dbo].[Parse_REN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'REN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, SocietyCode, Sequence, Note)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 3)
	, SUBSTRING(Row, 34, 4)
	, SUBSTRING(Row, 38, 20)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_REO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_REO
Description:	Parses all non-parsed REO rows.
*/

CREATE PROCEDURE [dbo].[Parse_REO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'REO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, SocietyCode, Sequence, Note)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 3)
	, SUBSTRING(Row, 34, 4)
	, SUBSTRING(Row, 38, 20)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_STA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_STA
Description:	Parses all non-parsed STA rows.
*/

CREATE PROCEDURE [dbo].[Parse_STA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_STD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_STD
Description:	Parses all non-parsed STD rows.
*/

CREATE PROCEDURE [dbo].[Parse_STD]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STD';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_STN]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_STN
Description:	Parses all non-parsed STN rows.
*/

CREATE PROCEDURE [dbo].[Parse_STN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPBNRef
	, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 13)
	, SUBSTRING(Row, 33, 1)
	, SUBSTRING(Row, 34, 8)
	, SUBSTRING(Row, 42, 6)	
	, SUBSTRING(Row, 48, 8)
	, SUBSTRING(Row, 56, 6)
	, SUBSTRING(Row, 62, 8)
	, SUBSTRING(Row, 70, 6)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_STO]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_STO
Description:	Parses all non-parsed STO rows.
*/

CREATE PROCEDURE [dbo].[Parse_STO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPBNRef
	, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 13)
	, SUBSTRING(Row, 33, 1)
	, SUBSTRING(Row, 34, 8)
	, SUBSTRING(Row, 42, 6)	
	, SUBSTRING(Row, 48, 8)
	, SUBSTRING(Row, 56, 6)
	, SUBSTRING(Row, 62, 8)
	, SUBSTRING(Row, 70, 6)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Parse_TMA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Parse_TMA
Description:	Parses all non-parsed TMA rows.
*/

CREATE PROCEDURE [dbo].[Parse_TMA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'TMA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TISN
	, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 4)
	, SUBSTRING(Row, 24, 8)
	, SUBSTRING(Row, 32, 20)
	, SUBSTRING(Row, 52, 8)	
	, SUBSTRING(Row, 60, 1)
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO
/****** Object:  StoredProcedure [dbo].[Process]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Process
Description:	Imports DIFFERENTIAL file(s) and processes all EDI IPI transactions.

ATTENTION:		DO NOT CALL THIS PROCEDURE FROM AN OUTER TRANSACTION!
				IN CASE OF A TRANSACTION FAILURE THE SESSION MANAGEMENT WILL FAIL AS WELL. 
				A DIFFERENCE BETWEEN THE SID-IN-MEMORY AND NON-EXISTING SID IN ROLLED BACK TABLE (dbo.Session) 
				WILL CAUSE THE FOREIGN KEY CONSTRAINT VIOLATION EXCEPTION.
*/

CREATE PROCEDURE [dbo].[Process]
	@SID int = NULL
AS

SET NOCOUNT ON;

DECLARE @ControllerResult AS int;
DECLARE @NextFile AS nvarchar(128);
DECLARE @Ret AS int;

-- Check database
BEGIN TRY		
	EXEC [dbo].[CheckDatabase];
END TRY
BEGIN CATCH
	THROW;
	RETURN;
END CATCH

BEGIN TRY

	-- DO NOT START if the database is not in READY state.
	IF dbo.IsReady() = 0
	BEGIN
		EXEC dbo.FastPrint 'Database is not READY. The processing cannot be started.';
		RAISERROR('Database is not READY. The processing cannot be started.', 16, 1);
	END;

	-- Session management: 
	-----------------------------------------------------------------------------------------------------------------
	-- Session can be initially created by the processing program which calls dbo.CreateSession procedure.
	-- This program then passes the @SID to this procedure and that session is supposed to be valid.
	-- If this procedure is called directly by user then the session is not yet created and the global SID variable
	-- holds value 0 which is invalid session value. In that case the session has to be (re)created.
	-----------------------------------------------------------------------------------------------------------------
	IF @SID IS NULL
	BEGIN
		EXEC dbo.ClearSession;	-- if called directly clear the in-memory session storage, just to be sure it is being cleared
	END;
	EXEC dbo.TryRecreateSession @SID;

	-- clear & reseed import table
	EXEC dbo.Initialize;

	-- check if import is feasible
	EXEC @ControllerResult = dbo.Controller @NextFile OUTPUT;
	IF @ControllerResult != 0
	BEGIN
		-- write log: import aborted
		EXEC dbo.SkipImport;
		GOTO Processing;
	END;

	-- execute differential import (at least one file should be imported)
	EXEC dbo.ImportDiff;

	-- parse imported data and store it into dbo.Row table as a raw data
	EXEC dbo.[Parse];

Processing:
	-- process all non-processed transactions and finalize the session.
	EXEC @Ret = dbo.ProcessTrans;

	-- All transactions already committed:
	IF @Ret = -1
	BEGIN
		GOTO Finalize;
	END;

	-- remove duplicates (only if any new transaction)
	EXEC dbo.RemoveDuplicates;

Finalize:
	-- finalize processing
	EXEC dbo.Finalize;

	-- Show statistics
	SELECT * FROM [dbo].[Statistics];

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;

	EXEC dbo.FastPrint '=============================================================';
	EXEC dbo.FastPrint 'THE PROCESSING FAILED. DATABASE IS IN NON-READY STATE.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	EXEC dbo.FastPrint '=============================================================';

	-- try recreate session (to be sure that logging will not fail)
	EXEC dbo.TryRecreateSession;

	-- write log
	EXEC dbo.WriteLog 0, @e, NULL, NULL;

END CATCH;

-- close the session
EXEC dbo.CloseSession;


GO
/****** Object:  StoredProcedure [dbo].[Process_IPA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Process_IPA
Description:	Process all IPA records from the initial TOTAL IMPORT into [ipi] schema.

Important:		HeaderID is the replacement for TranSeq as it is unique transaction identifier in the 
				entire dbo.Row table while the TranSeq is only unique in a single transaction file.

	IPA:IPA
	IPA:BDN
	IPA:STN
	IPA:NCN,ONN,MCN
	IPA:MAN
	IPA:TMA
	IPA:NTN
	IPA:NUN,INN
	IPA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Process_IPA]
AS

SET NOCOUNT ON;

BEGIN TRY

------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '10> IPA:IPA';
	INSERT INTO ipi.IP
	(RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex)
	SELECT RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex
	FROM dbo.[Row]
	WHERE 
		RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND HeaderCode = 'IPA'
		AND RowCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '20> IPA:BDN';
	WITH _BDN AS
	(
		SELECT
			A.RowID, B.Sex, B.[Type], B.BirthDate, B.DeathDate, B.BirthPlace, B.BirthState
			, B.TISN, B.TISNValidFrom, B.TISAN, B.TISANValidFrom, B.IEIndicator
			, B.AmendDate, B.AmendTime
		FROM dbo.[Row] AS A
		INNER JOIN dbo.[Row] AS B 
			ON A.RowID + 1 = B.RowID
		WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
			AND A.HeaderCode = 'IPA'
			AND B.RowCode = 'BDN'
	)
	UPDATE X
	SET 
		X.Sex = A.Sex
		, X.[Type] = A.[Type]
		, X.BirthDate = A.BirthDate
		, X.DeathDate = A.DeathDate
		, X.BirthPlace = A.BirthPlace
		, X.BirthState = A.BirthState
		, X.TISN = A.TISN
		, X.TISNValidFrom = A.TISNValidFrom
		, X.TISAN = A.TISAN
		, X.TISANValidFrom = A.TISANValidFrom
		, X.IEIndicator = A.IEIndicator
		, X.AmendDate = A.AmendDate
		, X.AmendTime = A.AmendTime
	FROM ipi.IP AS X
	INNER JOIN _BDN AS A
		ON X.RowID = A.RowID;
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '30> IPA:STN';
	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode = 'STN'
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '40> IPA:NCN,ONN,MCN';
	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('NCN','ONN','MCN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '50> IPA:MAN';
	EXEC dbo.Query_50_Init;

	-- The script below is intolerably slow! Consuming very large amount of too disk space (over 50GB for transaction log only).
	-- And it failed 3-times due to full transaction log (after processing in total over 24 hours.)
	-------------------------------------------------------------------------------------------------
	-- DO NOT RUN THIS SCRIPT UNLESS YOU HAVE 100GB DISK SPACE AND A ROCKET ENGINE.
	-------------------------------------------------------------------------------------------------
	/*
		EXEC dbo.FastPrint '50> IPA:MAN';
		INSERT INTO ipi.IPMembership
		(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
			, SignDate, MemberShare, AmendDate, AmendTime)

		SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
			, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

		-- data rows
		FROM dbo.[Row] AS A

		-- tran header row
		INNER JOIN dbo.[Row] AS H 
			ON H.RowCode = 'IPA'
				AND H.HeaderID = A.HeaderID		-- the same tran group

		INNER JOIN ipi.IP AS R
			ON H.IPBN = R.IPBN
		INNER JOIN ipi.IPName AS N 
			ON R.ID = N.ID
				AND H.IPNN = N.IPNN

		WHERE A.RowCode = 'MAN'
			AND A.HeaderCode = 'IPA'
			AND A.RowID <= 273810673;		-- DO NOT USE A VARIABLE (due to Query Tuning)
	*/
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '60> IPA:TMA';
	EXEC dbo.Query_60_Init;

	-------------------------------------------------------------------------------------------------
	-- THIS SCRIPT IS ALSO VERY SLOW. DO NOT RUN IT.
	-------------------------------------------------------------------------------------------------
	/*
		EXEC dbo.FastPrint '60> IPA:TMA';
		INSERT INTO ipi.IPMembershipTerritory
		(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
		SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
		FROM dbo.[Row] AS X

		-- find parent
		CROSS APPLY (
			SELECT TOP(1) AA.RowID, AA.MID
			FROM ipi.IPMembership AS AA
			INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
			WHERE AA.RowID < X.RowID
				AND BB.HeaderID = X.HeaderID	-- the same tran group
			ORDER BY AA.RowID DESC
		) AS A

		WHERE X.RowCode = 'TMA' 
			AND X.HeaderCode = 'IPA'
			AND X.RowID <= 273810673;		-- DO NOT USE A VARIABLE (due to Query Tuning)
	*/
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '70> IPA:NTN';
	INSERT INTO ipi.IPNationality
	(RowID, ID, TISN, TISNValidFrom, TISAN, TISANValidFrom, ValidFrom, ValidTo)
	SELECT 
		A.RowID
		, R.ID
		, A.TISN
		, A.TISNValidFrom
		, A.TISAN
		, A.TISANValidFrom
		, A.ValidFromDate
		, A.ValidToDate

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode = 'NTN'
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '80> IPA:NUN,INN';
	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	FROM dbo.[Row] AS A
	INNER JOIN ipi.IPName AS R
		ON A.IPNN = R.IPNN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('NUN','INN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '90> IPA:MUN,IMN';
	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode
	FROM dbo.[Row] AS A
	INNER JOIN ipi.IP AS S ON A.IPBN = S.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND S.ID = R.ID

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('MUN','IMN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------------';
	EXEC dbo.FastPrint 'IPA transactions have failed.';	
	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[ProcessHeader]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.ProcessHeader
Description:	A time consuming operation over dbo.RowHeader table split into smaller packages.
Expected speed:	1.000 rows/s (10s per package)
*/

CREATE PROCEDURE [dbo].[ProcessHeader]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET
		HeaderID = A.HeaderID
		, HeaderCode = A.HeaderCode
	FROM dbo.RowHeader AS X
	CROSS APPLY (
		SELECT TOP(1) AA.RowID AS HeaderID, AA.RowCode AS HeaderCode
		FROM dbo.RowHeader AS AA
		INNER JOIN dbo.RowCodes AS BB ON AA.RowCode = BB.RowCode
		WHERE X.RowID >= AA.RowID
			AND BB.IsHeader = 1
		ORDER BY AA.RowID DESC
	) AS A
	WHERE X.RowID BETWEEN @RowID1 AND @RowID2;
';

BEGIN TRY

DECLARE @msg AS nvarchar(MAX);
DECLARE @N AS int = 10000;	-- row volume that enters the transaction (keep it small)
DECLARE @RowID1 AS bigint = (SELECT MIN(RowID) FROM dbo.RowHeader);
DECLARE @RowID2 AS bigint = @RowID1 + @N;

-- MAX RowID
DECLARE @EndRowID AS bigint = (SELECT MAX(RowID) FROM dbo.RowHeader);

-- number of packages
DECLARE @NumberOfPackages AS int = ROUND(CAST((@EndRowID - @RowID1) AS float)/10000, 0) + 1;

SET @msg = 'Updating HeaderID in ' + CAST(@NumberOfPackages AS nvarchar(10)) + ' package(s). Please wait...';
EXEC dbo.FastPrint '---------------------------------------------------------';
EXEC dbo.FastPrint @msg;

-- loop
WHILE @RowID1 < @EndRowID
BEGIN

	EXEC sp_executesql @SQL
		, N'@RowID1 bigint, @RowID2 bigint'
		, @RowID1 = @RowID1
		, @RowID2 = @RowID2;

	EXEC dbo.FastPrint @NumberOfPackages;

	SET @RowID1 = @RowID1 + @N + 1;
	SET @RowID2 = @RowID1 + @N;
	SET @NumberOfPackages = @NumberOfPackages - 1;

END;

EXEC dbo.FastPrint '---------------------------------------------------------';
EXEC dbo.FastPrint 'Update of HeaderID is finished.';

END TRY
BEGIN CATCH
	THROW;
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[ProcessTrans]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.ProcessTrans
Description:	Processes all non-processed transactions from the last processed transaction on.

Note:			DO NOT CALL THIS PROCEDURE FROM AN OUTER TRANSACTION!
				IN CASE OF A TRANSACTION FAILURE THE SESSION MANAGEMENT WILL FAIL AS WELL. 
				A DIFFERENCE BETWEEN THE SID-IN-MEMORY AND NON-EXISTING SID IN ROLLED BACK TABLE (dbo.Session) 
				WILL CAUSE THE FOREIGN KEY CONSTRAINT VIOLATION EXCEPTION.
*/

CREATE PROCEDURE [dbo].[ProcessTrans]
	@EndHeaderID bigint = NULL				-- if NULL then upper limit is not defined (process ALL)
	, @DatabaseInProcessingState bit = 0	-- if 1 then this procedure has to continue with unprocessing transactions using the new SID (!!!)
AS

SET NOCOUNT ON;

-- get session variable
DECLARE @SID AS int = dbo.GetSID();

-- Prevent calling this procedure directly by user.
-- It should be called ONLY by the main dbo.Process procedure.
IF dbo.IsSessionValid() = 0
BEGIN

	-- throw exception 
	--    if database is not in PROCESSING state and this procedure is not called by dbo.ProcessUnfinished -
	--    which executes this procedure by @DatabaseInProcessingState = 1 param.
	IF @DatabaseInProcessingState = 0 OR dbo.IsProcessing() = 0
	BEGIN
		IF XACT_STATE() != 0 ROLLBACK;	
		RAISERROR('It was not intended to call the procedure dbo.ProcessTrans directly. Please use dbo.Process procedure instead.', 16, 1);
		RETURN;
	END;

	-- here we continue with the procerssing of the unfinished transactions
	-- Note: We use the last SID
	IF ISNULL(@SID, 0) = 0
	BEGIN

		-- create new SID
		EXEC [dbo].[TryRecreateSession];

	END;

END;

-- get session variable
--DECLARE @SID AS int = dbo.GetSID();

DECLARE @HeaderID AS bigint;
DECLARE @HeaderCode AS char(3);
DECLARE @msg AS nvarchar(MAX);
DECLARE @SQL AS nvarchar(MAX);

-- start try-catch block
BEGIN TRY

	------------------------------------------------------------------------------------------
	-- Gets and validates the beginning transaction.
	------------------------------------------------------------------------------------------

	DECLARE @BeginHeaderID AS bigint = [dbo].[FirstNonProcessedHeaderID]();

	-- check if there is any beginning transaction
	IF @BeginHeaderID IS NULL
	BEGIN
		EXEC dbo.FastPrint 'Attention: All transactions are commited. The processing will not start.';
		RETURN -1;
	END;

	------------------------------------------------------------------------------------------
	-- Start the cursor processing.
	------------------------------------------------------------------------------------------

	EXEC dbo.FastPrint 'The processing started...';

	DECLARE _CUR CURSOR LOCAL FAST_FORWARD
	FOR
		SELECT HeaderID, HeaderCode
		FROM [dbo].[Transaction]
		WHERE HeaderID BETWEEN @BeginHeaderID AND ISNULL(@EndHeaderID, 1000000000000000000);
	OPEN _CUR;
	FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Check if transaction is active. If not throw an exception. 
		-- It is important to understand that THE PROCESSING AS A WHOLE IS VALID ONLY
		-- IF ALL UNCOMMITED (ACTIVE) TRANSACTIONS ARE CONSECUTIVE (CHAINED) ONES UNTIL THE LAST TRANSACTION
		-- IN THE CHAIN AND THAT THERE IS NO INACTIVE GAPS (STATUS 2) IN THE TRANSACTION CHAIN.
		---------------------------------------------------------------------------------------------------------
		-- EVERY TRANSACTION FETCHED BY THIS CURSOR IS ANTICIPATED TO BE AN ACTIVE TRANSACTION.
		---------------------------------------------------------------------------------------------------------

		IF dbo.IsActive(@HeaderID) = 0
		BEGIN
			SET @msg = 'Transaction #' + CAST(ISNULL(@HeaderID, 0) AS nvarchar(15)) + ' is invalid (inactive).';
			RAISERROR(@msg, 16, 1);
			RETURN;
		END;
 
 		---------------------------------------------------------------------------------------------------------
		-- Mark the transaction as PROCESSING.
		---------------------------------------------------------------------------------------------------------

		EXEC dbo.SetTranAsProcessing @HeaderID;

 		---------------------------------------------------------------------------------------------------------
		-- Notify the console.
		---------------------------------------------------------------------------------------------------------

		SET @msg = '#' + CAST(@HeaderID AS nvarchar(15)) + '>' + @HeaderCode;
		EXEC dbo.FastPrint @msg;	

		---------------------------------------------------------------------------------------------------------
		-- Execute the transaction procedure.
		---------------------------------------------------------------------------------------------------------

		BEGIN TRANSACTION;

		SET @SQL = N'EXEC dbo.Tran_' + @HeaderCode + ' @HeaderID;';
		EXEC sp_executesql @SQL
			, N'@HeaderID bigint'
			, @HeaderID = @HeaderID;

		COMMIT;

 		---------------------------------------------------------------------------------------------------------
		-- Mark the transaction as COMMITED.
		---------------------------------------------------------------------------------------------------------

		EXEC dbo.SetTranAsCommited @HeaderID;
		
		---------------------------------------------------------------------------------------------------------

		FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;

	END;
	CLOSE _CUR;
	DEALLOCATE _CUR;

	EXEC dbo.FastPrint 'The processing completed.';

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;	

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	SET @msg = 'ERROR> ' + @e;
	EXEC dbo.FastPrint @msg;

	-- try recreate session (if called inside OUTER transaction)
	EXEC dbo.TryRecreateSession;

	-- handle process interuption
	EXEC dbo.SetInterrupted @SID, @HeaderID, @e;

	-- set transaction as failed
	EXEC [dbo].[SetTranAsFailed] @HeaderID;

	-- pass error to the caller
	RAISERROR(@e, @v, @s);

END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Query_10]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_10
Transaction:	IPA:IPA
*/

CREATE PROCEDURE [dbo].[Query_10]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IP
	(RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex)
	SELECT RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex
	FROM dbo.[Row]
	WHERE 
		HeaderID = @HeaderID
		AND HeaderCode = ''IPA''
		AND RowCode = ''IPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[Query_100]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_100
Transaction:	MAA:MAN
*/

CREATE PROCEDURE [dbo].[Query_100]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembership
	(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
		, SignDate, MemberShare, AmendDate, AmendTime)

	SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
		, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- tran header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''MAA'' 
			AND H.HeaderID = A.HeaderID 

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS N 
		ON R.ID = N.ID
			AND H.IPNN = N.IPNN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''MAN''
		AND A.HeaderCode = ''MAA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_110]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_110
Transaction:	MAA:TMA
*/

CREATE PROCEDURE [dbo].[Query_110]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembershipTerritory
	(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
	SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
	FROM dbo.[Row] AS X

	-- find parent
	CROSS APPLY (
		SELECT TOP(1) AA.RowID, AA.MID
		FROM ipi.IPMembership AS AA
		INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
		WHERE AA.RowID < X.RowID
			AND BB.HeaderID = X.HeaderID	-- the same tran group
		ORDER BY AA.RowID DESC
	) AS A

	WHERE X.RowCode = ''TMA''
		AND X.HeaderCode = ''MAA''
		AND X.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




	


GO
/****** Object:  StoredProcedure [dbo].[Query_120]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_120
Transaction:	NCA:NCN,ONN,MCN
*/

CREATE PROCEDURE [dbo].[Query_120]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''NCA'' 
			AND H.HeaderID = A.HeaderID 

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''NCN'',''ONN'',''MCN'')
		AND A.HeaderCode = ''NCA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_130]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_130
Transaction:	NCA:NUN,INN
*/

CREATE PROCEDURE [dbo].[Query_130]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode) 
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	FROM dbo.[Row] AS H

	-- NUN, INN (detail records)
	INNER JOIN dbo.[Row] AS A
		ON H.HeaderID = A.HeaderID

	INNER JOIN ipi.IP AS B ON H.IPBN = B.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND B.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND H.RowCode = ''NCA''
		AND A.RowCode IN (''NUN'',''INN'')
		AND A.HeaderCode = ''NCA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;
GO
/****** Object:  StoredProcedure [dbo].[Query_140]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_140
Transaction:	NCA:MUN,IMN
*/

CREATE PROCEDURE [dbo].[Query_140]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode) 
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode
	FROM dbo.[Row] AS A
	INNER JOIN ipi.IP AS S ON A.IPBN = S.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND S.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''MUN'',''IMN'')
		AND A.HeaderCode = ''NCA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





	
GO
/****** Object:  StoredProcedure [dbo].[Query_150]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_150
Transaction:	NPA:NCN
*/

CREATE PROCEDURE [dbo].[Query_150]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''NPA'' 
			AND H.HeaderID = A.HeaderID 

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NCN''
		AND A.HeaderCode = ''NPA''
		AND A.NameType = ''PA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





GO
/****** Object:  StoredProcedure [dbo].[Query_160]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_160
Transaction:	NPA:NCO+NCN 
*/

CREATE PROCEDURE [dbo].[Query_160]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET 
		RowID = B.RowID
		, NameType = B.NameType
		, Name = B.Name
		, FirstName = B.FirstName 
		, AmendDate = B.AmendDate
		, AmendTime = B.AmendTime
		, CreationDate = B.CreationDate
		, CreationTime = B.CreationTime
	FROM dbo.[Row] AS A				-- NCO (PA)
	INNER JOIN dbo.[Row] AS B		-- NCN (MO)
		ON A.RowID + 1 = B.RowID	-- next record MUST BE NCN
	INNER JOIN ipi.IPName AS X
		ON A.IPNN = X.IPNN
	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NCO''
		AND A.HeaderCode = ''NPA''
		AND B.RowCode = ''NCN''
		AND B.HeaderCode = ''NPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO
/****** Object:  StoredProcedure [dbo].[Query_170]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_170
Transaction:	NPA:NUN 
*/

CREATE PROCEDURE [dbo].[Query_170]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode
	FROM dbo.[Row] AS A
	INNER JOIN ipi.IPName AS R
		ON A.IPNN = R.IPNN

	-- find parent row
	CROSS APPLY (
		SELECT TOP(1) AA.SocietyCode
		FROM dbo.[Row] AS AA
		WHERE AA.RowCode = ''NPA''
			AND AA.HeaderID = A.HeaderID 
			AND AA.RowID < A.RowID
		ORDER BY AA.RowID DESC
	) AS B

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NUN''
		AND A.HeaderCode = ''NPA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




GO
/****** Object:  StoredProcedure [dbo].[Query_180]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_180
Transaction:	NTA:NTN 
*/

CREATE PROCEDURE [dbo].[Query_180]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNationality
	(RowID, ID, TISN, TISNValidFrom, TISAN, TISANValidFrom, ValidFrom, ValidTo)
	SELECT 
		A.RowID
		, R.ID
		, A.TISN
		, A.TISNValidFrom
		, A.TISAN
		, A.TISANValidFrom
		, A.ValidFromDate
		, A.ValidToDate

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''NTA'' 
			AND H.HeaderID = A.HeaderID 

	-- IP of a status row
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NTN'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




GO
/****** Object:  StoredProcedure [dbo].[Query_190]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_190
Transaction:	NUA:NUN,INN
*/

CREATE PROCEDURE [dbo].[Query_190]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode) 
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	-- NUA (we need header to obtain IPBN which is not given in detail record)
	FROM dbo.[Row] AS H

	-- NUN, INN (detail records)
	INNER JOIN dbo.[Row] AS A
		ON H.HeaderID = A.HeaderID

	INNER JOIN ipi.IP AS B ON H.IPBN = B.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND B.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND H.RowCode = ''NUA''
		AND A.RowCode IN (''NUN'',''INN'')
		AND A.HeaderCode = ''NUA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;






	

GO
/****** Object:  StoredProcedure [dbo].[Query_20]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_20
Transaction:	IPA:BDN
*/

CREATE PROCEDURE [dbo].[Query_20]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	WITH _BDN AS
	(
		SELECT
			A.RowID, B.Sex, B.[Type], B.BirthDate, B.DeathDate, B.BirthPlace, B.BirthState
			, B.TISN, B.TISNValidFrom, B.TISAN, B.TISANValidFrom, B.IEIndicator
			, B.AmendDate, B.AmendTime
		FROM dbo.[Row] AS A

		-- find BDN -- popravek 29.1.2018
		CROSS APPLY (
			SELECT TOP(1) BB.*
			FROM dbo.[Row] AS BB
			WHERE BB.RowCode = ''BDN''
				AND BB.RowID > A.RowID
				AND BB.HeaderID = @HeaderID	-- the same tran group
			ORDER BY BB.RowID DESC
		) AS B

		WHERE A.HeaderID = @HeaderID
			AND A.HeaderCode = ''IPA''
			AND B.RowCode = ''BDN''
	)
	UPDATE X
	SET 
		X.Sex = A.Sex
		, X.[Type] = A.[Type]
		, X.BirthDate = A.BirthDate
		, X.DeathDate = A.DeathDate
		, X.BirthPlace = A.BirthPlace
		, X.BirthState = A.BirthState
		, X.TISN = A.TISN
		, X.TISNValidFrom = A.TISNValidFrom
		, X.TISAN = A.TISAN
		, X.TISANValidFrom = A.TISANValidFrom
		, X.IEIndicator = A.IEIndicator
		, X.AmendDate = A.AmendDate
		, X.AmendTime = A.AmendTime
	FROM ipi.IP AS X
	INNER JOIN _BDN AS A
		ON X.RowID = A.RowID;	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO
/****** Object:  StoredProcedure [dbo].[Query_200]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_200
Transaction:	NUA:MUN,IMN
*/

CREATE PROCEDURE [dbo].[Query_200]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	FROM dbo.[Row] AS A
	INNER JOIN ipi.IP AS S ON A.IPBN = S.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND S.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''MUN'',''IMN'')
		AND A.HeaderCode = ''NUA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




GO
/****** Object:  StoredProcedure [dbo].[Query_210]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_210
Transaction:	STA:STN
Note:			
			    1. IPBNRef must be the same as the IPBN found in the transaction header record (IPA)
				   if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
			    2. IPBNRef must be different from IPBN found in the transaction header record (IPA) 
				   if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION). 
*/

CREATE PROCEDURE [dbo].[Query_210]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''STA'' 
			AND H.HeaderID = A.HeaderID 

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''STN''
		AND H.HeaderCode = ''STA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





	


GO
/****** Object:  StoredProcedure [dbo].[Query_220]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_220
Transaction:	BDU:BDN
*/

CREATE PROCEDURE [dbo].[Query_220]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET 
		RowID = A.RowID
		, Sex = A.Sex
		, [Type] = A.[Type]
		, BirthDate = A.BirthDate
		, DeathDate = A.DeathDate
		, BirthPlace = A.BirthPlace
		, BirthState = A.BirthState
		, TISN = A.TISN
		, TISNValidFrom = A.TISNValidFrom
		, TISAN = A.TISAN
		, TISANValidFrom = A.TISANValidFrom
		, IEIndicator = A.IEIndicator
		, AmendDate = A.AmendDate
		, AmendTime = A.AmendTime

	FROM dbo.[Row] AS A				-- BDN (data to update with)
	INNER JOIN dbo.[Row] AS B		-- BDU (header)
		ON A.HeaderID = B.HeaderID
	INNER JOIN ipi.IP AS X
		ON X.IPBN = B.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.HeaderCode = ''BDU''
		AND A.RowCode = ''BDN''
		AND B.RowCode = ''BDU'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_230]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_230
Transaction:	NTU:NTO
*/

CREATE PROCEDURE [dbo].[Query_230]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS A				-- NTU (header)
	INNER JOIN dbo.[Row] AS B		-- NTO 
		ON B.RowCode = ''NTO''
			AND A.HeaderID = B.HeaderID	
				
	INNER JOIN ipi.IP AS D
		ON A.IPBN = D.IPBN

	INNER JOIN ipi.IPNationality AS X
		ON X.ID = D.ID
			AND X.TISN = B.TISN
			AND X.ValidFrom = B.ValidFromDate
			AND X.ValidTo = B.ValidToDate
	WHERE A.HeaderID = @HeaderID
		AND A.HeaderCode = ''NTU'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_240]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_240
Transaction:	NTU:NTN
*/

CREATE PROCEDURE [dbo].[Query_240]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNationality
	(RowID, ID, TISN, TISNValidFrom, TISAN, TISANValidFrom, ValidFrom, ValidTo)
	SELECT 
		A.RowID
		, R.ID
		, A.TISN
		, A.TISNValidFrom
		, A.TISAN
		, A.TISANValidFrom
		, A.ValidFromDate
		, A.ValidToDate

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''NTU'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NTN''
		AND A.HeaderCode = ''NTU'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_250]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_250
Transaction:	MAU:MAO
*/

CREATE PROCEDURE [dbo].[Query_250]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	-- MAU
	FROM dbo.[Row] AS H	

	-- MAN
	INNER JOIN dbo.[Row] AS A 
		ON H.HeaderCode = ''MAU''
			AND H.RowCode = ''MAU''
			AND A.RowCode = ''MAO''
			AND H.HeaderID = A.HeaderID

	-- ipi
	INNER JOIN [ipi].[IP] AS B ON H.IPBN = B.IPBN
	INNER JOIN [ipi].[IPName] AS N ON B.ID = N.ID AND H.IPNN = N.IPNN
	INNER JOIN  [ipi].[IPMembership] AS X 
		ON N.NID = X.NID
			AND A.SocietyCode = X.SocietyCode
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode 
			AND A.RightCode = X.RightCode 
			AND A.ValidFromDate = X.ValidFromDate 
			AND A.ValidFromTime = X.ValidFromTime
			AND A.ValidToDate = X.ValidToDate 
			AND A.ValidToTime = X.ValidToTime

	WHERE A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_260]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_260
Transaction:	MAU:MAN
*/

CREATE PROCEDURE [dbo].[Query_260]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembership
	(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
		, SignDate, MemberShare, AmendDate, AmendTime)

	SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
		, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- tran header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''MAU'' 
			AND H.HeaderID = A.HeaderID 

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS N 
		ON R.ID = N.ID
			AND H.IPNN = N.IPNN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''MAN''
		AND A.HeaderCode = ''MAU'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





	

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_270]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_270
Transaction:	MAU:TMA
				-------------------------------------------------------------------------
Attention:		If your database has different COLLATION than the tempdb, then this 
				procedure will fail due to the collation conflict.

				In that case change the DATABASE_DEFAULT below in global temp table
				creation (##EDIPI_MembershipBuffer) by the collation of the tempdb.
				-------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[Query_270]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..##EDIPI_MembershipBuffer') IS NULL 
BEGIN
	CREATE TABLE ##EDIPI_MembershipBuffer
	(
		[RowID] [bigint] NOT NULL PRIMARY KEY,
		[RowCode] [varchar](3) COLLATE Slovenian_CI_AS NOT NULL,
		[SocietyCode] [char](3) COLLATE Slovenian_CI_AS NULL,
		[CCCode] [char](2) COLLATE Slovenian_CI_AS NULL,
		[RoleCode] [char](2) COLLATE Slovenian_CI_AS NULL,
		[RightCode] [char](2) COLLATE Slovenian_CI_AS NULL,
		[ValidFromDate] [char](8) COLLATE Slovenian_CI_AS NULL,
		[ValidFromTime] [char](6) COLLATE Slovenian_CI_AS NULL,
		[ValidToDate] [char](8) COLLATE Slovenian_CI_AS NULL,
		[ValidToTime] [char](6) COLLATE Slovenian_CI_AS NULL,

		-- membership territory
		TISN char(4) COLLATE Slovenian_CI_AS NULL,
		TISNValidFrom char(8) COLLATE Slovenian_CI_AS NULL,
		TISAN char(20) COLLATE Slovenian_CI_AS NULL,
		TISANValidFrom char(8) COLLATE Slovenian_CI_AS NULL,
		IEIndicator char(1) COLLATE Slovenian_CI_AS NULL,

		[RowN] [bigint] NULL,
	);
	CREATE NONCLUSTERED INDEX ix_##EDIPI_ParentWithEnding ON ##EDIPI_MembershipBuffer (RowCode, RowN);
END
ELSE BEGIN
	TRUNCATE TABLE ##EDIPI_MembershipBuffer;
END;

-- Insert ALL transaction data
INSERT INTO ##EDIPI_MembershipBuffer
(RowID, RowCode, SocietyCode, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator
	, RowN)
SELECT RowID, RowCode, SocietyCode, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator
	, ROW_NUMBER() OVER (
		PARTITION BY HeaderCode
		ORDER BY RowID) AS RowN
FROM dbo.[Row]
WHERE HeaderID = @HeaderID
	AND RowCode IN ('MAO', 'MAN', 'TMA');

-- Remove MAO-TMA records
DELETE B
FROM ##EDIPI_MembershipBuffer AS A			-- parent (MAO)
CROSS APPLY (								-- next parent (MAN)
	SELECT TOP(1) AA.RowID
	FROM ##EDIPI_MembershipBuffer AS AA
	WHERE AA.RowID > A.RowID
		AND AA.RowCode = 'MAN'
) AS Z
CROSS APPLY (								-- children (TMA)
	SELECT *
	FROM ##EDIPI_MembershipBuffer AS AA
	WHERE AA.RowID > A.RowID AND AA.RowID < Z.RowID
) AS B
WHERE A.RowCode = 'MAO';

-- Remove MAO records
DELETE FROM ##EDIPI_MembershipBuffer
WHERE RowCode = 'MAO';

IF NOT EXISTS (SELECT * FROM ##EDIPI_MembershipBuffer) RETURN;

-----------------------------------------------------------------------------------
-- Now ##EDIPI_MembershipBuffer contains only MAN-TMA records -> final insert
-----------------------------------------------------------------------------------

DECLARE @NID int;
SELECT @NID = N.NID 
	FROM dbo.[Row] AS H
	INNER JOIN [ipi].[IP] AS I ON H.IPBN = I.IPBN
	INNER JOIN [ipi].[IPName] AS N ON I.ID = N.ID AND H.IPNN = N.IPNN
	WHERE HeaderID = @HeaderID AND RowCode = 'MAU';

-- Final insert:
INSERT INTO ipi.IPMembershipTerritory
(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
SELECT A.RowID, M.MID, A.TISN, A.TISNValidFrom, A.TISAN, A.TISANValidFrom, A.IEIndicator
FROM (				-- MAN-TMA
	SELECT
		-- parents
		A.SocietyCode, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime 
		-- children
		, B.RowID, B.TISN, B.TISNValidFrom, B.TISAN, B.TISANValidFrom, B.IEIndicator
	FROM ##EDIPI_MembershipBuffer AS A			-- parent (MAN)
	OUTER APPLY (								-- next or last (empty) parent (MAN)
		SELECT TOP(1) AA.RowID
		FROM ##EDIPI_MembershipBuffer AS AA
		WHERE AA.RowID > A.RowID
			AND AA.RowCode = 'MAN'
	) AS Z
	CROSS APPLY (								-- children (TMA)
		SELECT *
		FROM ##EDIPI_MembershipBuffer AS AA
		WHERE AA.RowID > A.RowID AND AA.RowID < ISNULL(Z.RowID, 9223372036854775807)
	) AS B
	WHERE A.RowCode = 'MAN'
) AS A
-- join IPMembership (MAN) header
INNER JOIN  [ipi].[IPMembership] AS M 
	ON M.NID = @NID
		AND A.SocietyCode = M.SocietyCode
		AND A.CCCode = M.CCCode
		AND A.RoleCode = M.RoleCode 
		AND A.RightCode = M.RightCode 
		AND A.ValidFromDate = M.ValidFromDate 
		AND A.ValidFromTime = M.ValidFromTime
		AND A.ValidToDate = M.ValidToDate 
		AND A.ValidToTime = M.ValidToTime
;




GO
/****** Object:  StoredProcedure [dbo].[Query_280]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_280
Transaction:	NCU:NCO+NCN
*/

CREATE PROCEDURE [dbo].[Query_280]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET 
		RowID = B.RowID
		, NameType = B.NameType
		, Name = B.Name
		, FirstName = B.FirstName 
		, AmendDate = B.AmendDate
		, AmendTime = B.AmendTime
		, CreationDate = B.CreationDate
		, CreationTime = B.CreationTime

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- NCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''NCO''
	INNER JOIN dbo.[Row] AS B			-- NCN or ONN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			--AND B.RowCode = ''NCN''
			AND B.RowCode IN (''NCN'', ''ONN'')  -- ONN 
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN = H.IPBNNew;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;






	


	

	

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_290]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_290
Transaction:	NCU:NCO
*/

CREATE PROCEDURE [dbo].[Query_290]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- NCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''NCO''
	INNER JOIN dbo.[Row] AS B			-- NCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''NCN''
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





	



	


	

	

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_30]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_30
Transaction:	IPA:STN
Note:			
			    1. IPBNRef must be the same as the IPBN found in the transaction header record (IPA)
				   if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
			    2. IPBNRef must be different from IPBN found in the transaction header record (IPA) 
				   if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION). 
*/

CREATE PROCEDURE [dbo].[Query_30]
	@HeaderID AS bigint	
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''STN''
		AND A.HeaderCode = ''IPA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO
/****** Object:  StoredProcedure [dbo].[Query_300]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_300
Transaction:	NCU:NCN
*/

CREATE PROCEDURE [dbo].[Query_300]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- NCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''NCO''
	INNER JOIN dbo.[Row] AS B			-- NCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''NCN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNNew = C.IPBN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew
	
	-- to avoid UK exception !!! (13.2.2018)
	AND NOT EXISTS (
		SELECT NULL
		FROM ipi.IPName AS NN
		WHERE NN.ID = C.ID AND NN.IPNN = B.IPNN
	)
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

	



	


	

	

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_310]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_310
Transaction:	NCU:MCO
Note:			
				Before images (MCO) are used for consistency checks, 
				and to delete the multi IP name connection between the IP-NAME-NUMBER of the PG/HR 
				and the IP-BASE-NUMBER-ref. in the detail record.
*/

CREATE PROCEDURE [dbo].[Query_310]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- MCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''MCO''
	INNER JOIN dbo.[Row] AS B			-- MCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode IN (''MCN'', ''NCN'')
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew;	-- the relink condition (from one IP to another) 
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

	
GO
/****** Object:  StoredProcedure [dbo].[Query_311]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_311
Transaction:	NCU:MCN
Note:			
				Before images (MCO) are used for consistency checks, 
				and to delete the multi IP name connection between the IP-NAME-NUMBER of the PG/HR 
				and the IP-BASE-NUMBER-ref. in the detail record.
*/

CREATE PROCEDURE [dbo].[Query_311]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)

	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- MCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''MCO''
	INNER JOIN dbo.[Row] AS B			-- MCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode IN (''MCN'', ''NCN'')
	INNER JOIN ipi.IP AS C
		ON H.IPBNNew = C.IPBN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew;	-- the relink condition (from one IP to another)

';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO
/****** Object:  StoredProcedure [dbo].[Query_320]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_320
Transaction:	NCU:ONO
Note:			Before images (ONO) are used for consistency checks, 
				and to delete the other name connection between the IP-NAME-NUMBER and the IP-NAME-NUMBER-ref. 
				in the detail record (Other name of an IP name entity).
*/

CREATE PROCEDURE [dbo].[Query_320]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- ONO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''ONO''
	INNER JOIN dbo.[Row] AS B			-- ONN (must be next to ONO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''ONN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[Query_321]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_321
Transaction:	NCU:ONN
Note:			Transaction query contains a variable @HeaderID in WHERE clause. Query tuning requires a constant value. 
				(That's why we use a dynamic SQL.)

				Remark on transaction:
				------------------------------------------------------------------------------------------------
				Before images (ONO) are used for consistency checks, 
				and to delete the other name connection between the IP-NAME-NUMBER and the IP-NAME-NUMBER-ref. 
				in the detail record (Other name of an IP name entity).
*/

CREATE PROCEDURE [dbo].[Query_321]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)

	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- ONO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''ONO''
	INNER JOIN dbo.[Row] AS B			-- ONN (must be next to ONO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''ONN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



	
	



	


	

	

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_330]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_330
Transaction:	NCU: MCO,ONO+NCN 
				(PG->PP) ***NON-DOCUMENTED
*/

CREATE PROCEDURE [dbo].[Query_330]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET 
		RowID = B.RowID
		, NameType = B.NameType
		, Name = B.Name
		, FirstName = B.FirstName 
		, AmendDate = B.AmendDate
		, AmendTime = B.AmendTime
		, CreationDate = B.CreationDate
		, CreationTime = B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- MCO,ONO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode IN (''MCO'',''ONO'')
	INNER JOIN dbo.[Row] AS B			-- NCN (must be next to MCO,ONO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''NCN''
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN = H.IPBNNew;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_340]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_340
Transaction:	NCU:IMO
Note:			Before images (IMO) are used to delete all existing connections (Name usage entity).
*/

CREATE PROCEDURE [dbo].[Query_340]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- IMO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''IMO''
	INNER JOIN dbo.[Row] AS B			-- IMN (must be next to IMO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''IMN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[Query_350]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_350
Transaction:	NCU:IMN
Note:			After images (IMN) are used to add all needed connections. (Name usage entity).
*/

CREATE PROCEDURE [dbo].[Query_350]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		B.RowID
		, D.NID
		, B.CCCode
		, B.RoleCode

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- IMO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''IMO''
	INNER JOIN dbo.[Row] AS B			-- IMN (must be next to IMO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''IMN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




GO
/****** Object:  StoredProcedure [dbo].[Query_360]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_360
Transaction:	NCU:INO
Note:			Before images (INO) are used to delete all existing connections (Name usage entity).
*/

CREATE PROCEDURE [dbo].[Query_360]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- INO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''INO''
	INNER JOIN dbo.[Row] AS B			-- INN (must be next to INO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''INN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_370]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_370
Transaction:	NCU:INN
Note:			After images (INN) are used to add all needed connections. (Name usage entity).
*/

CREATE PROCEDURE [dbo].[Query_370]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		B.RowID
		, D.NID
		, B.CCCode
		, B.RoleCode

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- INO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''INO''
	INNER JOIN dbo.[Row] AS B			-- INN (must be next to INO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''INN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_380]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_380
Transaction:	MAD:MAO
Note:			By deleting the membership record all territory agreements will be deleted as well
				(due to the DELETE CASACADE FK definition).
*/

CREATE PROCEDURE [dbo].[Query_380]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	-- MAD
	FROM dbo.[Row] AS H	

	-- MAN
	INNER JOIN dbo.[Row] AS A 
		ON H.HeaderCode = ''MAD''
			AND H.RowCode = ''MAD''
			AND A.RowCode = ''MAO''
			AND H.HeaderID = A.HeaderID

	-- ipi
	INNER JOIN [ipi].[IP] AS B ON H.IPBN = B.IPBN
	INNER JOIN [ipi].[IPName] AS N ON B.ID = N.ID AND H.IPNN = N.IPNN
	INNER JOIN  [ipi].[IPMembership] AS X 
		ON N.NID = X.NID
			AND A.SocietyCode = X.SocietyCode
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode 
			AND A.RightCode = X.RightCode 
			AND A.ValidFromDate = X.ValidFromDate 
			AND A.ValidFromTime = X.ValidFromTime
			AND A.ValidToDate = X.ValidToDate 
			AND A.ValidToTime = X.ValidToTime

	WHERE A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;




GO
/****** Object:  StoredProcedure [dbo].[Query_390]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_390
Transaction:	NUD:INO,NUO,MUO,IMO
*/

CREATE PROCEDURE [dbo].[Query_390]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NUD
	INNER JOIN dbo.[Row] AS A			-- INO,NUO,MUO,IMO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NUD''
			AND H.RowCode = ''NUD''
			AND A.RowCode IN (''INO'',''NUO'',''MUO'',''IMO'')
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[Query_40]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_40
Transaction:	IPA:NCN,ONN,MCN
Note:			
			    1. IPBNRef must be the same as the IPBN found in the transaction header record (IPA)
				   if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
			    2. IPBNRef must be different from IPBN found in the transaction header record (IPA) 
				   if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION). 
*/

CREATE PROCEDURE [dbo].[Query_40]
	@HeaderID AS bigint	
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''NCN'',''ONN'',''MCN'')
		AND A.HeaderCode = ''IPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;
GO
/****** Object:  StoredProcedure [dbo].[Query_400]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_400
Transaction:	NCD:MCO
*/

CREATE PROCEDURE [dbo].[Query_400]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NCD
	INNER JOIN dbo.[Row] AS A			-- MCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCD''
			AND H.RowCode = ''NCD''
			AND A.RowCode = ''MCO''
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS X 
		ON R.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;










	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_410]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_410
Transaction:	NTD:NTO
*/

CREATE PROCEDURE [dbo].[Query_410]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H				-- NTD (header)
	INNER JOIN dbo.[Row] AS A		-- NTO 
		ON A.RowCode = ''NTO''
			AND H.HeaderCode = ''NTD''
			AND H.HeaderID = A.HeaderID	
				
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN

	INNER JOIN ipi.IPNationality AS X
		ON X.ID = C.ID
			AND X.TISN = A.TISN
			AND X.ValidFrom = A.ValidFromDate
			AND X.ValidTo = A.ValidToDate
	WHERE A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;













	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_420]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_420
Transaction:	STD:STO
*/

CREATE PROCEDURE [dbo].[Query_420]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H				-- STD (header)
	INNER JOIN dbo.[Row] AS A		-- STO 
		ON A.RowCode = ''STO''
			AND H.HeaderCode = ''STD''
			AND H.HeaderID = A.HeaderID	
				
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN

	INNER JOIN ipi.IPStatus AS X
		ON X.ID = C.ID
			AND X.StatusCode = A.StatusCode
			AND X.ValidFromDate = A.ValidFromDate
			AND X.ValidFromTime = A.ValidFromTime
			AND X.ValidToDate = A.ValidToDate
			AND X.ValidToTime = A.ValidToTime

	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;














	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_430]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_430
Transaction:	STD:STN
Note:			
				1. IPBNRef must be the same as the IPBN found in the transaction header record (STA)
					if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
				2. IPBNRef must be different from IPBN found in the transaction header record (STA) 
					if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION).
*/

CREATE PROCEDURE [dbo].[Query_430]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''STD'' 
			AND H.HeaderID = A.HeaderID 

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''STN''
		AND H.HeaderCode = ''STD'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;






	







	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_50]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_50
Transaction:	IPA:MAN
*/

CREATE PROCEDURE [dbo].[Query_50]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembership
	(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
		, SignDate, MemberShare, AmendDate, AmendTime)

	SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
		, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- tran header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA''
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS N 
		ON R.ID = N.ID
			AND H.IPNN = N.IPNN

	WHERE A.RowCode = ''MAN''
		AND A.HeaderCode = ''IPA''
		AND A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





GO
/****** Object:  StoredProcedure [dbo].[Query_50_Init]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_50_Init
Description:	Initial insert of IPA:MAN records using loop.
				If the query is executed against the whole amount of source data 
				the transaction log grows beyond 50GBa and fills up all the disk space.
				The duration of the non-limited transaction is over 10 hours. 
				At the end the disk gets full and transaction is rolled back.
Expected time:	1h30
Transaction:	IPA:MAN
*/

CREATE PROCEDURE [dbo].[Query_50_Init]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembership
	(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
		, SignDate, MemberShare, AmendDate, AmendTime)

	SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
		, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- tran header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA''
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS N 
		ON R.ID = N.ID
			AND H.IPNN = N.IPNN

	WHERE A.RowCode = ''MAN''
		AND A.HeaderCode = ''IPA''
		AND A.RowID BETWEEN @RowID1 AND @RowID2;		-- DO NOT USE A VARIABLE (due to Query Tuning)

	SET @RowCount = @@ROWCOUNT;
';

BEGIN TRY

-- loop

DECLARE @i AS int = 0;
DECLARE @N AS int = 10000;	-- row volume that enters the transaction (keep it small)
DECLARE @RowID1 AS bigint = 0;
DECLARE @RowID2 AS bigint = @N;
DECLARE @msg AS nvarchar(1000);
DECLARE @RowCount AS int;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop started...';

WHILE @RowID1 < 273810673
BEGIN

	EXEC sp_executesql @SQL
		, N'@RowID1 bigint, @RowID2 bigint, @RowCount int OUTPUT'
		, @RowID1 = @RowID1
		, @RowID2 = @RowID2
		, @RowCount = @RowCount OUTPUT;

	SET @msg = CAST(@i+1 AS nvarchar(10)) + '> ' + CAST(@RowCount AS nvarchar(10)) + ' rows';
	EXEC dbo.FastPrint @msg;

	SET @i = @i + 1;
	SET @RowID1 = @i * @N + 1;
	SET @RowID2 = (@i + 1) * @N;

END;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop finished.';

END TRY
BEGIN CATCH
	THROW;
END CATCH;

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_60]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_60
Transaction:	IPA:TMA
*/

CREATE PROCEDURE [dbo].[Query_60]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembershipTerritory
	(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
	SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
	FROM dbo.[Row] AS X

	-- find parent
	CROSS APPLY (
		SELECT TOP(1) AA.RowID, AA.MID
		FROM ipi.IPMembership AS AA
		INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
		WHERE AA.RowID < X.RowID
			AND BB.HeaderID = X.HeaderID	-- the same tran group
		ORDER BY AA.RowID DESC
	) AS A

	WHERE X.RowCode = ''TMA'' 
		AND X.HeaderCode = ''IPA''
		AND X.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO
/****** Object:  StoredProcedure [dbo].[Query_60_Init]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_60_Init
Description:	Initial insert of IPA:TMA records using loop.
				If the query is executed against the whole amount of source data 
				the transaction log grows beyond 50GBa and fills up all the disk space.
				The duration of the non-limited transaction is over 10 hours. 
				At the end the disk gets full and transaction is rolled back.
Expected time:	10h
Transaction:	IPA:TMA
*/

CREATE PROCEDURE [dbo].[Query_60_Init]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembershipTerritory
	(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)

	SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
	FROM dbo.[Row] AS X

	-- find parent
	CROSS APPLY (
		SELECT TOP(1) AA.RowID, AA.MID
		FROM ipi.IPMembership AS AA
		INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
		WHERE AA.RowID < X.RowID
			AND BB.HeaderID = X.HeaderID	-- the same tran group
		ORDER BY AA.RowID DESC
	) AS A

	WHERE X.RowCode = ''TMA'' 
		AND X.HeaderCode = ''IPA''
		AND X.RowID BETWEEN @RowID1 AND @RowID2;		-- DO NOT USE A VARIABLE (due to Query Tuning)

	SET @RowCount = @@ROWCOUNT;
';

BEGIN TRY

-- loop

DECLARE @i AS int = 0;
DECLARE @N AS int = 10000;	-- row volume that enters the transaction (keep it small)
DECLARE @RowID1 AS bigint = 0;
DECLARE @RowID2 AS bigint = @N;
DECLARE @msg AS nvarchar(1000);
DECLARE @RowCount AS int;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop started...';

WHILE @RowID1 < 273810673
BEGIN

	EXEC sp_executesql @SQL
		, N'@RowID1 bigint, @RowID2 bigint, @RowCount int OUTPUT'
		, @RowID1 = @RowID1
		, @RowID2 = @RowID2
		, @RowCount = @RowCount OUTPUT;

	SET @msg = CAST(@i+1 AS nvarchar(10)) + '> ' + CAST(@RowCount AS nvarchar(10)) + ' rows';
	EXEC dbo.FastPrint @msg;

	SET @i = @i + 1;
	SET @RowID1 = @i * @N + 1;
	SET @RowID2 = (@i + 1) * @N;

END;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop finished.';

END TRY
BEGIN CATCH
	THROW;
END CATCH;

	




	
	
	

	


GO
/****** Object:  StoredProcedure [dbo].[Query_70]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_70
Transaction:	IPA:NTN
*/

CREATE PROCEDURE [dbo].[Query_70]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNationality
	(RowID, ID, TISN, TISNValidFrom, TISAN, TISANValidFrom, ValidFrom, ValidTo)
	SELECT 
		A.RowID
		, R.ID
		, A.TISN
		, A.TISNValidFrom
		, A.TISAN
		, A.TISANValidFrom
		, A.ValidFromDate
		, A.ValidToDate

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NTN''
		AND A.HeaderCode = ''IPA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[Query_80]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_80
Transaction:	IPA:NUN,INN
*/

CREATE PROCEDURE [dbo].[Query_80]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	-- IPA (we need header to obtain IPBN which is not given in detail record)
	FROM dbo.[Row] AS H

	-- NUN, INN (detail records)
	INNER JOIN dbo.[Row] AS A
		ON H.HeaderID = A.HeaderID

	INNER JOIN ipi.IP AS B ON H.IPBN = B.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND B.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND H.RowCode = ''IPA''
		AND A.RowCode IN (''NUN'',''INN'')
		AND A.HeaderCode = ''IPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;
	

GO
/****** Object:  StoredProcedure [dbo].[Query_90]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_90
Transaction:	IPA:MUN,IMN
*/

CREATE PROCEDURE [dbo].[Query_90]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode
	FROM dbo.[Row] AS A
	INNER JOIN ipi.IP AS S ON A.IPBN = S.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND S.ID = R.ID

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''MUN'',''IMN'')
		AND A.HeaderCode = ''IPA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO
/****** Object:  StoredProcedure [dbo].[RemoveDuplicates]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.RemoveDuplicates
Description:		Safely removes IP name usage duplicates.
*/

CREATE PROCEDURE [dbo].[RemoveDuplicates]
AS   

-- NameUsage
WITH _Duplicates AS
(
	SELECT NID, CCCode, RoleCode
	FROM [ipi].[IPNameUsage]
	GROUP BY 
		[NID]
		, [CCCode]
		, [RoleCode]
	HAVING COUNT(*) > 1
)
DELETE X
FROM (
	SELECT B.NUID
		, ROW_NUMBER() OVER (
			PARTITION BY B.NID, B.CCCode, B.RoleCode
			ORDER BY B.[NUID] DESC 
		) AS RowN
	FROM _Duplicates AS A
	INNER JOIN [ipi].[IPNameUsage] AS B 
		ON A.NID = B.NID
		AND A.CCCode = B.CCCode
		AND A.RoleCode = B.RoleCode
) AS T
INNER JOIN [ipi].[IPNameUsage] AS X ON X.NUID = T.NUID
WHERE T.RowN > 1;

EXEC dbo.FastPrint 'Duplicates of IPNameUsage removed.';


GO
/****** Object:  StoredProcedure [dbo].[ReprocessTrans]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.ReprocessTrans
-------------------------------------------------------------------------------------------
				CURRENTLY ADJUSTED FOR NAME(USAGE) CORRECTIONS ONLY.
-------------------------------------------------------------------------------------------
Description:	Re-processes the transactions whose IsReprocess field is set to 1.

Note:			THIS PROCEDURE IS INTENDED FOR DATA CORRECTION. USE IT WITH CARE AND ONLY IN CASES WHEN DATA IS INCORRECT. 
				PRIOR TO USE MAKE SURE THAT THE NECESSARY CORRECTIONS OF THE RE-PROCESSING PROCEDURES HAVE BEEN DONE.
*/

CREATE PROCEDURE [dbo].[ReprocessTrans]
	@ID bigint
AS

SET NOCOUNT ON;

-- set default session 
DECLARE @SID AS int = 0;	-- re-processing SID

DECLARE @HeaderID AS bigint;
DECLARE @HeaderCode AS char(3);
DECLARE @msg AS nvarchar(MAX);

-- start try-catch block
BEGIN TRY
	BEGIN TRANSACTION;

	------------------------------------------------------------------------------------------
	-- Reset re-processing flag
	------------------------------------------------------------------------------------------
	
	UPDATE [dbo].[Transaction]
	SET [IsReprocess] = 0
	WHERE [IsReprocess] = 1;

	------------------------------------------------------------------------------------------
	-- Delete names
	------------------------------------------------------------------------------------------

	DELETE X
	FROM [ipi].[IPNameUsage] AS X
	INNER JOIN [ipi].[IPName] AS A ON X.NID = A.NID
	WHERE A.ID = @ID;
	EXEC dbo.FastPrint 'DELETE> ipi.IPNameUsage';

	DELETE X
	FROM [ipi].[IPName] AS X
	WHERE X.ID = @ID;
	EXEC dbo.FastPrint 'DELETE> ipi.IPName';

	------------------------------------------------------------------------------------------
	-- Mark re-processing transactions
	------------------------------------------------------------------------------------------

	DECLARE @IPBN AS char(13);
	SELECT @IPBN = IPBN
	FROM ipi.IP 
	WHERE ID = @ID;

	UPDATE X
	SET X.IsReprocess = 1
	FROM [dbo].[Transaction] AS X

	-- select only data of a given @ID
	WHERE EXISTS (
		SELECT NULL
		FROM (SELECT DISTINCT HeaderID
			FROM [dbo].[Row]
			WHERE IPBN = @IPBN
		) AS AA
		WHERE AA.HeaderID = X.HeaderID		
	)

	-- select only names data
	AND EXISTS (
		SELECT NULL
		FROM (SELECT DISTINCT HeaderCode
			FROM [dbo].[TransactionRecordInfo]
			WHERE [IsNameRecord] = 1
		) AS AA
		WHERE AA.HeaderCode = X.HeaderCode
	);

	-- check
	IF @@ROWCOUNT = 0
	BEGIN
		EXEC dbo.FastPrint 'No transaction has been specified for the re-processing.';
		ROLLBACK;
		RETURN;
	END;

	------------------------------------------------------------------------------------------
	-- Start the cursor processing.
	------------------------------------------------------------------------------------------

	EXEC dbo.FastPrint 'The processing started...';

	DECLARE _CUR CURSOR LOCAL FAST_FORWARD
	FOR
		SELECT HeaderID, HeaderCode
		FROM [dbo].[Transaction]
		WHERE IsReprocess = 1
		ORDER BY HeaderID
	OPEN _CUR;
	FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @msg = '#' + CAST(@HeaderID AS nvarchar(15)) + '>' + @HeaderCode;
		EXEC dbo.FastPrint @msg;	

		EXEC dbo.Query_40 @HeaderID;
		EXEC dbo.Query_80 @HeaderID;
		EXEC dbo.Query_90 @HeaderID;
		EXEC dbo.Query_120 @HeaderID;
		EXEC dbo.Query_130 @HeaderID;
		EXEC dbo.Query_140 @HeaderID;
		EXEC dbo.Query_150 @HeaderID;
		EXEC dbo.Query_160 @HeaderID;
		EXEC dbo.Query_170 @HeaderID;
		EXEC dbo.Query_190 @HeaderID;
		EXEC dbo.Query_200 @HeaderID;
		EXEC dbo.Query_280 @HeaderID;
		EXEC dbo.Query_290 @HeaderID;
		EXEC dbo.Query_300 @HeaderID;
		EXEC dbo.Query_310 @HeaderID;
		EXEC dbo.Query_311 @HeaderID;
		EXEC dbo.Query_320 @HeaderID;
		EXEC dbo.Query_321 @HeaderID;
		EXEC dbo.Query_330 @HeaderID;
		EXEC dbo.Query_340 @HeaderID;
		EXEC dbo.Query_350 @HeaderID;
		EXEC dbo.Query_360 @HeaderID;
		EXEC dbo.Query_370 @HeaderID;
		EXEC dbo.Query_390 @HeaderID;
		EXEC dbo.Query_400 @HeaderID;

		FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;

	END;
	CLOSE _CUR;
	DEALLOCATE _CUR;

	COMMIT TRANSACTION;

	EXEC dbo.FastPrint 'The processing completed.';

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;	

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	SET @msg = 'ERROR> ' + @e;
	EXEC dbo.FastPrint @msg;

	-- pass error to the caller
	RAISERROR(@e, @v, @s);

END CATCH;



GO
/****** Object:  StoredProcedure [dbo].[RestoreMembership]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.RestoreMembership
Description:	Restore membership data for a given N interested parties.		 
*/

CREATE PROCEDURE [dbo].[RestoreMembership]
	@N int = 10			-- how many IPs to restore
AS

SET NOCOUNT ON;

BEGIN TRY

	IF @N <= 0
	BEGIN
		PRINT 'N must be greater than zero.';
		RETURN;
	END;

--------------------------------------------------------
-- Select N IPs
--------------------------------------------------------

	CREATE TABLE #IDS (ID int NOT NULL PRIMARY KEY);

	-- get top @N which can be restored
	IF @N IS NOT NULL
	BEGIN
		INSERT INTO #IDS
		SELECT TOP(@N) ID
		FROM [dbo].[Restore] AS A
		WHERE CanRestore = 1
		ORDER BY ID;
	END
	ELSE BEGIN
		INSERT INTO #IDS
		SELECT ID
		FROM [dbo].[Restore] AS A
		WHERE ForProcessing = 1	
			AND CanRestore = 1
	END;

	IF @@ROWCOUNT = 0
	BEGIN
		PRINT 'No data to restore. Check CanRestore flag in [dbo].[Restore] table.';
		RETURN;
	END;

	-- update processing status
	UPDATE X
	SET X.ForProcessing = 1
	FROM [dbo].[Restore] AS X
	WHERE X.ID IN (SELECT ID FROM #IDS);

--------------------------------------------------------
-- Initialize restore by counting 
-- current membership data.
--------------------------------------------------------

	EXEC dbo.InitializeRestore;

--------------------------------------------------------
-- Disable reject triggers
--------------------------------------------------------

	ALTER TABLE [ipi].[IPMembership] DISABLE TRIGGER [IPMembership_RejectTrigger];
	ALTER TABLE [ipi].[IPMembership] DISABLE TRIGGER [IPMembership_DeleteBuffer];
	ALTER TABLE [ipi].[IPMembershipTerritory] DISABLE TRIGGER [IPMembershipTerritory_RejectTrigger];

--------------------------------------------------------
-- Loop through IPs and run RestoreMembershipByIP
-- (for every IP)
--------------------------------------------------------

	EXEC dbo.FastPrint 'Processing started...';

	DECLARE @Ret int;
	DECLARE @k int = 1;
	DECLARE @ID int;

	-- cursor			
	DECLARE cur1 CURSOR LOCAL READ_ONLY FOR
		SELECT ID FROM #IDS;	
	OPEN cur1;
	FETCH NEXT FROM cur1 INTO @ID;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--EXEC dbo.FastPrint @ID;

		EXEC [dbo].[RestoreMembershipByIP] @ID;

		IF @k % 1000 = 0 EXEC dbo.FastPrint @k;
		SET @k = @k + 1;

		FETCH NEXT FROM cur1 INTO @ID;
	END	
	CLOSE cur1;
	DEALLOCATE cur1;
	
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 ROLLBACK;	
	DECLARE @e NVARCHAR(MAX) = 'ERROR: ' + ERROR_MESSAGE(); 
	INSERT INTO [dbo].[RestoreLog] (ID, HeaderID, [Message]) 
		VALUES (ISNULL(@ID, -1), -2, @e);
	EXEC dbo.FastPrint @e;
END CATCH;

--------------------------------------------------------
-- Enable reject triggers
--------------------------------------------------------

ALTER TABLE [ipi].[IPMembership] ENABLE TRIGGER [IPMembership_RejectTrigger];
ALTER TABLE [ipi].[IPMembership] ENABLE TRIGGER [IPMembership_DeleteBuffer];
ALTER TABLE [ipi].[IPMembershipTerritory] ENABLE TRIGGER [IPMembershipTerritory_RejectTrigger];

--------------------------------------------------------
-- Finalizer
--------------------------------------------------------

EXEC FinalizeRestore;

EXEC dbo.FastPrint 'Membership restore completed.';
GO
/****** Object:  StoredProcedure [dbo].[RestoreMembershipByIP]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Object:			dbo.RestoreMembershipByIP
Description:	Restores all membership data (IPMembership + IPMembershipTerritory)
				for a given IP from the first to the last membership transaction.
Note:			This procedure eliminates all current membership data for IP
				and imports data from the raw source (dbo.Raw). No file import is needed 
				unless the raw source is empty.				 
*/

CREATE PROCEDURE [dbo].[RestoreMembershipByIP]
	@ID int
AS

SET NOCOUNT ON;

DECLARE @IPBN char(13) = (SELECT IPBN FROM ipi.IP WHERE ID = @ID);

DECLARE @HeaderID bigint = -1;
BEGIN TRY

	BEGIN TRANSACTION;

	-- set processing status
	UPDATE [dbo].[Restore]
	SET IsProcessing = 1
	WHERE ID = @ID;

	-- remove membership data
	DELETE FROM ipi.IPMembership
	WHERE ID = @ID;

	-- begin cursor			
	DECLARE cur1 CURSOR LOCAL READ_ONLY FOR
		SELECT DISTINCT HeaderID
		FROM dbo.[Row]
		WHERE IPBN = @IPBN
			AND HeaderCode IN ('IPA', 'MAA', 'MAD', 'MAN', 'MAO', 'MAU')
		ORDER BY HeaderID;
	
	OPEN cur1;

	FETCH NEXT FROM cur1 INTO @HeaderID;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--EXEC dbo.FastPrint @HeaderID;

		-- IPA:MAN
		EXEC dbo.Query_50 @HeaderID;

		-- IPA:TMA
		EXEC dbo.Query_60 @HeaderID;

		-- MAA:MAN
		EXEC dbo.Query_100 @HeaderID;
			
		-- MAA:TMA
		EXEC dbo.Query_110 @HeaderID;

		-- MAD:MAO
		EXEC dbo.Query_380 @HeaderID;

		-- MAU:MAO
		EXEC dbo.Query_250 @HeaderID;

		-- MAU:MAN
		EXEC dbo.Query_260 @HeaderID;

		-- MAU:TMA
		EXEC dbo.Query_270 @HeaderID;

		FETCH NEXT FROM cur1 INTO @HeaderID;
	END	-- cursor

	CLOSE cur1;
	DEALLOCATE cur1;
	-- end of cursor

	-- update restore table
	UPDATE [dbo].[Restore]
	SET CanRestore = 0
		, IsProcessing = 0
	WHERE ID = @ID;

	COMMIT;

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 ROLLBACK;	
	DECLARE @e NVARCHAR(MAX) = 'ERROR: ' + ERROR_MESSAGE(); 
	INSERT INTO [dbo].[RestoreLog] (ID, HeaderID, [Message]) VALUES (@ID, @HeaderID, @e);
	EXEC dbo.FastPrint @e;

	-- set processing status
	UPDATE [dbo].[Restore]
	SET IsProcessing = 0
	WHERE ID = @ID;

	RETURN -1;    -- NOT OK
END CATCH;

RETURN 0;	-- OK
GO
/****** Object:  StoredProcedure [dbo].[SetContextData]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetContectData
Description:	Sets CONTEXT_INFO variable associated with the current session or connection.
*/

CREATE PROCEDURE [dbo].[SetContextData]
	@DATA As varchar(128)

AS 

DECLARE  @CONTEXT_INFO varbinary(128);

SELECT  @CONTEXT_INFO = 
	Cast(Cast(@DATA As varchar(127)) +
	Space(128) As binary(128));			-- add WHITESPACE up to fill up 128 bytes
	
SET CONTEXT_INFO @CONTEXT_INFO;


GO
/****** Object:  StoredProcedure [dbo].[SetInterrupted]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetInterrupted
Description:	Sets the database state as INTERRUPTED and writes a log record.
Note:			This procedure is called after the transaction has FAILED. 
*/

CREATE PROCEDURE [dbo].[SetInterrupted]
	@SID int					-- SID where an error occured
	, @HeaderID bigint			-- transaction inside which an error occured
	, @Message nvarchar(MAX)	-- log (error) message
AS

SET NOCOUNT ON;

-- set database state
UPDATE dbo.[Config] SET [DatabaseState] = 2;

-- write a log
INSERT INTO [dbo].[Interrupted]
([SID], HeaderID, [Message])
VALUES (dbo.GetSID(), @HeaderID, @Message);

DECLARE @InterruptedID int = SCOPE_IDENTITY(); 

-- write log
EXEC dbo.WriteLog 0, 'Processing was interrupted.', @InterruptedID, 2;

GO
/****** Object:  StoredProcedure [dbo].[SetReady]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetReady
Description:	Sets the database state as READY.
Note:			This procedure is called after the transaction has SUCCEEDED.
				Accessable from DWH database as well. 
*/

CREATE PROCEDURE [dbo].[SetReady]
AS

SET NOCOUNT ON;

-- set database state
UPDATE dbo.[Config] SET [DatabaseState] = 0;

GO
/****** Object:  StoredProcedure [dbo].[SetTranAsCommited]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetTranAsCommited
Description:	Sets the transaction as commited.
Note:			This procedure is called after the transaction has been SUCCESSFULLY commited. 
*/

CREATE PROCEDURE [dbo].[SetTranAsCommited]
	@HeaderID int	
AS

SET NOCOUNT ON;

-- transaction table
UPDATE [dbo].[Transaction]
SET [TransactionStatus] = 2
	, [EndTime] = GETDATE()
WHERE HeaderID = @HeaderID;

-- database configuration table
UPDATE dbo.Config
SET [LastCommitedHeaderID] = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[SetTranAsFailed]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetTranAsFailed
Description:	Sets the transaction as failed.
Note:			This procedure is called after the transaction has FAILED and is ROLLED BACK. 
*/

CREATE PROCEDURE [dbo].[SetTranAsFailed]
	@HeaderID int	
AS

SET NOCOUNT ON;

UPDATE [dbo].[Transaction]
SET [TransactionStatus] = -1
WHERE HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[SetTranAsProcessing]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SetTranAsProcessing
Description:	Sets the transaction as commited.
Note:			This procedure is called before the PROCESSING of the transaction starts. 
*/

CREATE PROCEDURE [dbo].[SetTranAsProcessing]
	@HeaderID int	
AS

SET NOCOUNT ON;

-- set database state to PROCESSING
UPDATE dbo.[Config] SET [DatabaseState] = 1;

UPDATE [dbo].[Transaction]
SET [TransactionStatus] = 1
	, [BeginTime] = GETDATE()
WHERE HeaderID = @HeaderID;


GO
/****** Object:  StoredProcedure [dbo].[SkipImport]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.SkipImport
Description:	Skip the import if database is up-to-date or the consecutive file is missing.
Note:			---------------------------------------------------------------
				Only logging is performed by this procedure. No other action.
				---------------------------------------------------------------
				This procedure is called in the main procedure after the initial controller check fails.
*/

CREATE PROCEDURE [dbo].[SkipImport]
AS

SET NOCOUNT ON;

DECLARE @msg AS nvarchar(500)
DECLARE @FileNotFound AS nvarchar(128) = dbo.ComputeNextFile();

-- database is up-to-date
IF @FileNotFound IS NULL
BEGIN
	SET @msg = 'Database is up-to-date.';
	EXEC dbo.WriteLog 1, @msg, NULL, 0;
END
-- file not found
ELSE BEGIN
	SET @msg = 'File ' + @FileNotFound + ' not found. Import skipped.';
	EXEC dbo.FastPrint @msg;
	EXEC dbo.WriteLog 0, @msg, NULL, 0;
END;




GO
/****** Object:  StoredProcedure [dbo].[Tran_BDU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_BDU
Description:	Process all BDU records for of a given transaction.

	BDU:BDN

*/

CREATE PROCEDURE [dbo].[Tran_BDU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_220 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_IPA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_IPA
Description:	Process all IPA records for of a given transaction.

	IPA:IPA
	IPA:BDN
	IPA:STN
	IPA:NCN,ONN,MCN
	IPA:MAN
	IPA:TMA
	IPA:NTN
	IPA:NUN,INN
	IPA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_IPA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_10 @HeaderID;
	EXEC dbo.Query_20 @HeaderID;
	EXEC dbo.Query_30 @HeaderID;
	EXEC dbo.Query_40 @HeaderID;
	EXEC dbo.Query_50 @HeaderID;
	EXEC dbo.Query_60 @HeaderID;
	EXEC dbo.Query_70 @HeaderID;
	EXEC dbo.Query_80 @HeaderID;
	EXEC dbo.Query_90 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_MAA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_MAA
Description:	Process all MAA records for of a given transaction.

	MAA:MAN
	MAA:TMA

*/

CREATE PROCEDURE [dbo].[Tran_MAA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_100 @HeaderID;
	EXEC dbo.Query_110 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_MAD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_MAD
Description:	Process all MAD records for of a given transaction.

	MAD:MAO

*/

CREATE PROCEDURE [dbo].[Tran_MAD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_380 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_MAU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_MAU
Description:	Process all MAU records for of a given transaction.

	MAU:MAO
	MAU:MAN
	MAU:TMA

*/

CREATE PROCEDURE [dbo].[Tran_MAU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_250 @HeaderID;
	EXEC dbo.Query_260 @HeaderID;
	EXEC dbo.Query_270 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NCA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NCA
Description:	Process all NCA records for of a given transaction.

	NCA:NCN,ONN,MCN
	NCA:NUN,INN
	NCA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_NCA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_120 @HeaderID;
	EXEC dbo.Query_130 @HeaderID;
	EXEC dbo.Query_140 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NCD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NCD
Description:	Process all NCD records for of a given transaction.

	NCD:MCO

*/

CREATE PROCEDURE [dbo].[Tran_NCD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_400 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NCU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NCU
Description:	Process all NCU records for of a given transaction.

	NCU:NCO+NCN
	NCU:NCO
	NCU:NCN
	NCU:MCO
	NCU:MCN
	NCU:ONO
	NCU:ONN
	NCU:MCO,ONO+NCN
	NCU:IMO
	NCU:IMN
	NCU:INO
	NCU:INN

*/

CREATE PROCEDURE [dbo].[Tran_NCU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_280 @HeaderID;
	EXEC dbo.Query_290 @HeaderID;
	EXEC dbo.Query_300 @HeaderID;
	EXEC dbo.Query_310 @HeaderID;
	EXEC dbo.Query_311 @HeaderID;
	EXEC dbo.Query_320 @HeaderID;
	EXEC dbo.Query_321 @HeaderID;
	EXEC dbo.Query_330 @HeaderID;
	EXEC dbo.Query_340 @HeaderID;
	EXEC dbo.Query_350 @HeaderID;
	EXEC dbo.Query_360 @HeaderID;
	EXEC dbo.Query_370 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NPA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NPA
Description:	Process all NPA records for of a given transaction.

	NPA:NCN
	NPA:NCO+NCN
	NPA:NUN

*/

CREATE PROCEDURE [dbo].[Tran_NPA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_150 @HeaderID;
	EXEC dbo.Query_160 @HeaderID;
	EXEC dbo.Query_170 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NTA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NTA
Description:	Process all NTA records for of a given transaction.

	NTA:NTN

*/

CREATE PROCEDURE [dbo].[Tran_NTA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_180 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NTD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NTD
Description:	Process all NTD records for of a given transaction.

	NTD:NTO

*/

CREATE PROCEDURE [dbo].[Tran_NTD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_410 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NTU]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NTU
Description:	Process all NTU records for of a given transaction.

	NTU:NTO
	NTU:NTN

*/

CREATE PROCEDURE [dbo].[Tran_NTU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_230 @HeaderID;
	EXEC dbo.Query_240 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NUA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NUA
Description:	Process all NUA records for of a given transaction.

	NUA:NUN,INN
	NUA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_NUA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_190 @HeaderID;
	EXEC dbo.Query_200 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_NUD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_NUD
Description:	Process all NUD records for of a given transaction.

	NUD:INO,NUO,MUO,IMO

*/

CREATE PROCEDURE [dbo].[Tran_NUD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_390 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_STA]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_STA
Description:	Process all STA records for of a given transaction.

	STA:STN

*/

CREATE PROCEDURE [dbo].[Tran_STA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_210 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[Tran_STD]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_STD
Description:	Process all STD records for of a given transaction.

	STD:STO
	STD:STN

*/

CREATE PROCEDURE [dbo].[Tran_STD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_420 @HeaderID;
	EXEC dbo.Query_430 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO
/****** Object:  StoredProcedure [dbo].[TryRecreateSession]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.TryRecreateSession
Description:	Checks if SID exists in dbo.Session table and if not SID the session is recreated:
					- new session record is inserted
					- the SID variable is assigned with the new value
Note:			In case of a ROLLBACK in the dbo.ProcessTrans procedure the session is removed 
				from the dbo.Session table but the memory variable remains intact. This procedure helps 
				to reestablish the initial match between the table and the variable value. 
*/

CREATE PROCEDURE [dbo].[TryRecreateSession]
	@SID AS int = NULL	-- if given then the validation will be executed against this value
						-- and not against the SID value from global CONTEXT_DATA variable
AS

SET NOCOUNT ON;

-- SID management
SET @SID = ISNULL(@SID, dbo.GetSID());
EXEC [dbo].[SetContextData] @SID;

IF dbo.IsSessionValid() = 0
BEGIN

	INSERT INTO [dbo].[Session] DEFAULT VALUES;
	SET @SID = SCOPE_IDENTITY();	

	DECLARE @msg AS nvarchar(1000) = 'New session ' + CAST(@SID AS nvarchar(10)) + ' is created.';
	EXEC dbo.FastPrint @msg;

END;

-- restore the global variable
EXEC [dbo].[SetContextData] @SID;



GO
/****** Object:  StoredProcedure [dbo].[UpdateParseStatus]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.UpdateParseStatus
Description:	Sets the IsParsed flag in dbo.Import to TRUE.
*/

CREATE PROCEDURE [dbo].[UpdateParseStatus]
	@RowCode char(3),
	@Version char(5)
AS

UPDATE dbo.Import
SET IsParsed = 1
WHERE RowCode = @RowCode
	AND IsParsed = 0
	AND ErrorID = 0;

GO
/****** Object:  StoredProcedure [dbo].[ValidateRowLength]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.ValidateRowLength
Description:	Validates the row length in dbo.Import.
*/

CREATE PROCEDURE [dbo].[ValidateRowLength]
	@RowCode char(3),
	@Version char(5)	
AS

UPDATE dbo.Import
SET ErrorID = 2
WHERE RowCode = @RowCode
	AND [Version] = @Version
	AND LEN(Row) != (SELECT [Length] FROM dbo.RowCodes WHERE RowCode = @RowCode);


GO
/****** Object:  StoredProcedure [dbo].[WriteLog]    Script Date: 16. 04. 2020 23:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.WriteLog
Description:	Inserts the log record (at the end of processing).
*/

CREATE PROCEDURE [dbo].[WriteLog]
	@IsOK bit
	, @Message AS nvarchar(MAX)
	, @InterruptedID AS int
	, @DatabaseState AS int
AS 

SET NOCOUNT ON;

-- get SID
DECLARE @SID AS int = dbo.GetSID();

-- if @DatabaseState IS NULL => fetch it from the Config table
IF @DatabaseState IS NULL
BEGIN
	SELECT TOP(1) @DatabaseState = DatabaseState
	FROM dbo.[Config];
END;

INSERT INTO [dbo].[Log] ([SID], [IsOK], [Message], [InterruptedID], [DatabaseState])
VALUES (@SID, @IsOK, @Message, @InterruptedID, @DatabaseState);
