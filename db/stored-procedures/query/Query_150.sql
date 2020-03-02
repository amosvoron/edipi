
/*
Object:			dbo.Query_150
Transaction:	NPA:NCN
*/

CREATE PROCEDURE [dbo].[Query_150]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''NPA'' 
			AND H.HeaderID = A.HeaderID 

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''NCN''
		AND A.HeaderCode = ''NPA''
		AND A.NameType = ''PA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;





GO


