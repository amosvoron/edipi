
/*
Object:			dbo.Query_270_FORCED (WITH FORCED EXECUTION PLAN)
Transaction:	MAU:TMA
				-------------------------------------------------------------------------
Attention:		ONLY THOSE TMA RECORDS CAN GET INSERTED WHICH BELONGS TO THE MAN PARENT.
				Skip MAO:TMA records! These should be deleted.
				-------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[Query_270_FORCED]
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

		Updated int NOT NULL DEFAULT(0) 
	);
	CREATE NONCLUSTERED INDEX ix_##EDIPI_ParentWithEnding ON ##EDIPI_MembershipBuffer (RowCode, RowN, Updated);
END
ELSE BEGIN
	TRUNCATE TABLE ##EDIPI_MembershipBuffer;
END;

-- Insert parent data

INSERT INTO ##EDIPI_MembershipBuffer
(RowID, RowCode, SocietyCode, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, RowN)
SELECT RowID, RowCode, SocietyCode, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, ROW_NUMBER() OVER (
		PARTITION BY HeaderCode
		ORDER BY RowID) AS RowN
FROM dbo.[Row]
WHERE HeaderCode = 'MAU'
	AND RowCode IN ('MAN', 'MAO')
	AND HeaderID = @HeaderID;

-- exit if empty

IF NOT EXISTS (SELECT * FROM ##EDIPI_MembershipBuffer) RETURN;

-- Fake MAO ending since the last MAN block does not have it.

INSERT INTO ##EDIPI_MembershipBuffer
(RowID, RowCode, SocietyCode, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, RowN)
SELECT 
	(SELECT MAX(RowID) FROM dbo.[Row] WHERE HeaderID = @HeaderID) + 1 AS RowID
	, 'MAO' AS RowCode
	, NULL AS SocietyCode
	, NULL AS CCCode
	, NULL AS RoleCode
	, NULL AS RightCode
	, NULL AS ValidFromDate
	, NULL AS ValidFromTime
	, NULL AS ValidToDate
	, NULL AS ValidToTime
	, (SELECT MAX(RowN) FROM ##EDIPI_MembershipBuffer) + 1 AS RowN
;

-----------------------------------------------------------------------------------
-- ATTENTION!!!
--   WE FORCE THE PLAN 3 FOR QUERY BELOW (QUERY 3) - IN QUERY STORE
-----------------------------------------------------------------------------------
UPDATE A
SET A.Updated = 1
FROM ##EDIPI_MembershipBuffer AS A
LEFT OUTER JOIN ##EDIPI_MembershipBuffer AS B 
	ON B.RowCode = 'MAO'
		AND A.RowN + 1 = B.RowN
INNER JOIN dbo.[Row] AS C ON C.RowID BETWEEN A.RowID AND B.RowID
WHERE A.RowCode = 'MAN' AND C.RowCode = 'TMA';

-----------------------------------------------------------------------------------

-- Final insert:
INSERT INTO ipi.IPMembershipTerritory
(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
SELECT A.RowID, M.MID, A.TISN, A.TISNValidFrom, A.TISAN, A.TISANValidFrom, A.IEIndicator
FROM ##EDIPI_MembershipBuffer AS A	
CROSS JOIN (SELECT IPBN, IPNN 
	FROM dbo.[Row] 
	WHERE HeaderID = @HeaderID
		AND RowCode = 'MAU') AS H
INNER JOIN [ipi].[IP] AS I ON H.IPBN = I.IPBN
INNER JOIN [ipi].[IPName] AS N ON I.ID = N.ID AND H.IPNN = N.IPNN
INNER JOIN  [ipi].[IPMembership] AS M 
	ON N.NID = M.NID
		AND A.SocietyCode = M.SocietyCode
		AND A.CCCode = M.CCCode
		AND A.RoleCode = M.RoleCode 
		AND A.RightCode = M.RightCode 
		AND A.ValidFromDate = M.ValidFromDate 
		AND A.ValidFromTime = M.ValidFromTime
		AND A.ValidToDate = M.ValidToDate 
		AND A.ValidToTime = M.ValidToTime
WHERE A.Updated = 1;




GO


