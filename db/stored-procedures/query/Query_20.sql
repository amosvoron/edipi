
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


