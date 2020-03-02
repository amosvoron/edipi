
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


