
/*
Object:			dbo.Query_300
Transaction:	NCU:NCN
*/

CREATE PROCEDURE [dbo].[Query_300]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- NCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''NCO''
	INNER JOIN dbo.[Row] AS B			-- NCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''NCN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNNew = C.IPBN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew
	
	-- to avoid UK exception !!! (13.2.2018)
	AND NOT EXISTS (
		SELECT NULL
		FROM ipi.IPName AS NN
		WHERE NN.ID = C.ID AND NN.IPNN = B.IPNN
	)
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

	



	


	

	

	




	
	
	

	


GO


