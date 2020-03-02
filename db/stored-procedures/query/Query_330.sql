
/*
Object:			dbo.Query_330
Transaction:	NCU: MCO,ONO+NCN 
				(PG->PP) ***NON-DOCUMENTED
*/

CREATE PROCEDURE [dbo].[Query_330]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET 
		RowID = B.RowID
		, NameType = B.NameType
		, Name = B.Name
		, FirstName = B.FirstName 
		, AmendDate = B.AmendDate
		, AmendTime = B.AmendTime
		, CreationDate = B.CreationDate
		, CreationTime = B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- MCO,ONO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode IN (''MCO'',''ONO'')
	INNER JOIN dbo.[Row] AS B			-- NCN (must be next to MCO,ONO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''NCN''
	INNER JOIN ipi.IP AS C
		ON H.IPBN = C.IPBN
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN = H.IPBNNew;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO


