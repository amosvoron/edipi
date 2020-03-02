USE [EDIPI]
GO


/*
Object:			dbo.Query_390
Transaction:	NUD:INO,NUO,MUO,IMO
*/

CREATE PROCEDURE [dbo].[Query_390]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

	FROM dbo.[Row] AS H					-- NUD
	INNER JOIN dbo.[Row] AS A			-- INO,NUO,MUO,IMO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NUD''
			AND H.RowCode = ''NUD''
			AND A.RowCode IN (''INO'',''NUO'',''MUO'',''IMO'')
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


