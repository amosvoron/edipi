
/*
Object:			dbo.Query_250
Transaction:	MAU:MAO
*/

CREATE PROCEDURE [dbo].[Query_250]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	-- MAU
	FROM dbo.[Row] AS H	

	-- MAN
	INNER JOIN dbo.[Row] AS A 
		ON H.HeaderCode = ''MAU''
			AND H.RowCode = ''MAU''
			AND A.RowCode = ''MAO''
			AND H.HeaderID = A.HeaderID

	-- ipi
	INNER JOIN [ipi].[IP] AS B ON H.IPBN = B.IPBN
	INNER JOIN [ipi].[IPName] AS N ON B.ID = N.ID AND H.IPNN = N.IPNN
	INNER JOIN  [ipi].[IPMembership] AS X 
		ON N.NID = X.NID
			AND A.SocietyCode = X.SocietyCode
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode 
			AND A.RightCode = X.RightCode 
			AND A.ValidFromDate = X.ValidFromDate 
			AND A.ValidFromTime = X.ValidFromTime
			AND A.ValidToDate = X.ValidToDate 
			AND A.ValidToTime = X.ValidToTime

	WHERE A.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



	




	
	
	

	


GO


