
/*
Object:			dbo.Query_400
Transaction:	NCD:MCO
*/

CREATE PROCEDURE [dbo].[Query_400]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NCD
	INNER JOIN dbo.[Row] AS A			-- MCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCD''
			AND H.RowCode = ''NCD''
			AND A.RowCode = ''MCO''
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS X 
		ON R.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;










	
	
	

	


GO


