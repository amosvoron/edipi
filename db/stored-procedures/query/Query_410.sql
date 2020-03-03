
/*
Object:			dbo.Query_410
Transaction:	NTD:NTO
*/

CREATE PROCEDURE [dbo].[Query_410]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H				-- NTD (header)
	INNER JOIN dbo.[Row] AS A		-- NTO 
		ON A.RowCode = ''NTO''
			AND H.HeaderCode = ''NTD''
			AND H.HeaderID = A.HeaderID	
				
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN

	INNER JOIN ipi.IPNationality AS X
		ON X.ID = C.ID
			AND X.TISN = A.TISN
			AND X.ValidFrom = A.ValidFromDate
			AND X.ValidTo = A.ValidToDate
	WHERE A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;













	
	
	

	


GO


