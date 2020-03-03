
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


