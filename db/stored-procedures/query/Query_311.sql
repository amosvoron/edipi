
/*
Object:			dbo.Query_311
Transaction:	NCU:MCN
Note:			
				Before images (MCO) are used for consistency checks, 
				and to delete the multi IP name connection between the IP-NAME-NUMBER of the PG/HR 
				and the IP-BASE-NUMBER-ref. in the detail record.
*/

CREATE PROCEDURE [dbo].[Query_311]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)

	SELECT B.RowID, C.ID, B.IPNN, B.NameType, B.Name, B.FirstName, B.AmendDate, B.AmendTime, B.CreationDate, B.CreationTime
	FROM dbo.[Row] AS H					-- NCU
	INNER JOIN dbo.[Row] AS A			-- MCO
		ON H.HeaderID = A.HeaderID	
			AND H.HeaderCode = ''NCU''
			AND H.RowCode = ''NCU''
			AND A.RowCode = ''MCO''
	INNER JOIN dbo.[Row] AS B			-- MCN (must be next to NCO)
		ON H.HeaderID = B.HeaderID	
			AND A.RowID + 1 = B.RowID
			AND B.RowCode IN (''MCN'', ''NCN'')
	INNER JOIN ipi.IP AS C
		ON H.IPBNNew = C.IPBN
	WHERE H.HeaderID = @HeaderID
		AND H.IPBN != H.IPBNNew;	-- the relink condition (from one IP to another)

';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO

