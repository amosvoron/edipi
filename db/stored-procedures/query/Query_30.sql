
/*
Object:			dbo.Query_30
Transaction:	IPA:STN
Note:			
			    1. IPBNRef must be the same as the IPBN found in the transaction header record (IPA)
				   if the StatusCode is 1 (SELF REFERENCE) or 4 (TOTAL LOGICAL DELETION).
			    2. IPBNRef must be different from IPBN found in the transaction header record (IPA) 
				   if the StatusCode is 2 (PURCHASE) or 3 (LOGICAL DELETION). 
*/

CREATE PROCEDURE [dbo].[Query_30]
	@HeaderID AS bigint	
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA'' 
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.HeaderID = @HeaderID
		AND A.RowCode = ''STN''
		AND A.HeaderCode = ''IPA'';
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;

GO


