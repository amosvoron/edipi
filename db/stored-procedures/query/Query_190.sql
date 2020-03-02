
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


