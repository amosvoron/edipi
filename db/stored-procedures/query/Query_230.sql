
/*
Object:			dbo.Query_230
Transaction:	NTU:NTO
*/

CREATE PROCEDURE [dbo].[Query_230]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS A				-- NTU (header)
	INNER JOIN dbo.[Row] AS B		-- NTO 
		ON B.RowCode = ''NTO''
			AND A.HeaderID = B.HeaderID	
				
	INNER JOIN ipi.IP AS D
		ON A.IPBN = D.IPBN

	INNER JOIN ipi.IPNationality AS X
		ON X.ID = D.ID
			AND X.TISN = B.TISN
			AND X.ValidFrom = B.ValidFromDate
			AND X.ValidTo = B.ValidToDate
	WHERE A.HeaderID = @HeaderID
		AND A.HeaderCode = ''NTU'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

	
	

	


GO


