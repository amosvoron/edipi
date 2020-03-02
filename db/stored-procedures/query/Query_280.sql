
/*
Object:			dbo.Query_280
Transaction:	NCU:NCO+NCN
*/

CREATE PROCEDURE [dbo].[Query_280]
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
	INNER JOIN dbo.[Row] AS A			-- NCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''NCO''
	INNER JOIN dbo.[Row] AS B			-- NCN or ONN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			--AND B.RowCode = ''NCN''
			AND B.RowCode IN (''NCN'', ''ONN'')  -- ONN 
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


