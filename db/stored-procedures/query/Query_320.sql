USE [EDIPI]
GO

/****** Object:  StoredProcedure [dbo].[Query_320]    Script Date: 2. 03. 2020 09:49:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Query_320
Transaction:	NCU:ONO
Note:			Before images (ONO) are used for consistency checks, 
				and to delete the other name connection between the IP-NAME-NUMBER and the IP-NAME-NUMBER-ref. 
				in the detail record (Other name of an IP name entity).
*/

CREATE PROCEDURE [dbo].[Query_320]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	DELETE X

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
	INNER JOIN ipi.IPName AS X
		ON C.ID = X.ID
			AND A.IPNN = X.IPNN
	WHERE H.HeaderID = @HeaderID;
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO


