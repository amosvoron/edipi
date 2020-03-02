
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


