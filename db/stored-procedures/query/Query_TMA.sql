
/*
Object:			dbo.Query_TMA
Transaction:	IPA:TMA, MAA:TMA
Description:	Prepare global temp membership buffer.
*/

CREATE PROCEDURE [dbo].[Query_TMA]
	@HeaderID bigint
	, @HeaderCode char(3)
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
	AND HeaderCode = @HeaderCode
	AND RowCode IN ('MAO', 'MAN', 'TMA');	-- include MAO for MAU transaction

IF @@ROWCOUNT = 0 RETURN;

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

-- get NID
DECLARE @NID int;
SELECT @NID = N.NID 
	FROM dbo.[Row] AS H
	INNER JOIN [ipi].[IP] AS I ON H.IPBN = I.IPBN
	INNER JOIN [ipi].[IPName] AS N ON I.ID = N.ID AND H.IPNN = N.IPNN
	WHERE HeaderID = @HeaderID AND RowCode = @HeaderCode;

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


