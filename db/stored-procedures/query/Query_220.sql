
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


