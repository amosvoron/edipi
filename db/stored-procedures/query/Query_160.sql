
/*
Object:			dbo.Query_160
Transaction:	NPA:NCO+NCN 
*/

CREATE PROCEDURE [dbo].[Query_160]
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
	FROM dbo.[Row] AS A				-- NCO (PA)
	INNER JOIN dbo.[Row] AS B		-- NCN (MO)
		ON A.RowID + 1 = B.RowID	-- next record MUST BE NCN
	INNER JOIN ipi.IPName AS X
		ON A.IPNN = X.IPNN
	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NCO''
		AND A.HeaderCode = ''NPA''
		AND B.RowCode = ''NCN''
		AND B.HeaderCode = ''NPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO


