
/*
Object:			dbo.Query_370
Transaction:	NCU:INN
Note:			After images (INN) are used to add all needed connections. (Name usage entity).
*/

CREATE PROCEDURE [dbo].[Query_370]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		B.RowID
		, D.NID
		, B.CCCode
		, B.RoleCode

	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- INO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''INO''
	INNER JOIN dbo.[Row] AS B			-- INN (must be next to INO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''INN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	INNER JOIN ipi.IPName AS D
		ON C.ID = D.ID
			AND A.IPNN = D.IPNN
	INNER JOIN ipi.IPNameUsage AS X
		ON D.NID = X.NID
			AND A.CCCode = X.CCCode
			AND A.RoleCode = X.RoleCode
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;



GO


