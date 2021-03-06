
/*
Object:			dbo.Query_321
Transaction:	NCU:ONN
Note:			Transaction query contains a variable @HeaderID in WHERE clause. Query tuning requires a constant value. 
				(That's why we use a dynamic SQL.)

				Remark on transaction:
				------------------------------------------------------------------------------------------------
				Before images (ONO) are used for consistency checks, 
				and to delete the other name connection between the IP-NAME-NUMBER and the IP-NAME-NUMBER-ref. 
				in the detail record (Other name of an IP name entity).
*/

CREATE PROCEDURE [dbo].[Query_321]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)

	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- ONO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''ONO''
	INNER JOIN dbo.[Row] AS B			-- ONN (must be next to ONO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode = ''ONN''
	INNER JOIN ipi.IP AS C
		ON H.IPBNRef = C.IPBN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

