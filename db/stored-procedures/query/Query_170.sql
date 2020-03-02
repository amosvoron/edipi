
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


