
/*
Object:			dbo.Query_40
Transaction:	IPA:NCN,ONN,MCN
Note:			
			    1. IPBNRef must be the same as the IPBN found in the transaction header record (IPA)
				   if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
			    2. IPBNRef must be different from IPBN found in the transaction header record (IPA) 
				   if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION). 
*/

CREATE PROCEDURE [dbo].[Query_40]
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
		ON H.RowCode = ''IPA'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode IN (''NCN'',''ONN'',''MCN'')
		AND A.HeaderCode = ''IPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;
