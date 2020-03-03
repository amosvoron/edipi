
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


