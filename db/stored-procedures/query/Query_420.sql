
/*
Object:			dbo.Query_420
Transaction:	STD:STO
*/

CREATE PROCEDURE [dbo].[Query_420]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H				-- STD (header)
	INNER JOIN dbo.[Row] AS A		-- STO 
		ON A.RowCode = ''STO''
			AND H.HeaderCode = ''STD''
			AND H.HeaderID = A.HeaderID	
				
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN

	INNER JOIN ipi.IPStatus AS X
		ON X.ID = C.ID
			AND X.StatusCode = A.StatusCode
			AND X.ValidFromDate = A.ValidFromDate
			AND X.ValidFromTime = A.ValidFromTime
			AND X.ValidToDate = A.ValidToDate
			AND X.ValidToTime = A.ValidToTime

	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;














	
	
	

	


GO


