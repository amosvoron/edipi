
/*
Object:			dbo.Query_50_Init
Description:	Initial insert of IPA:MAN records using loop.
				If the query is executed against the whole amount of source data 
				the transaction log grows beyond 50GBa and fills up all the disk space.
				The duration of the non-limited transaction is over 10 hours. 
				At the end the disk gets full and transaction is rolled back.
Expected time:	1h30
Transaction:	IPA:MAN
*/

CREATE PROCEDURE [dbo].[Query_50_Init]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembership
	(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
		, SignDate, MemberShare, AmendDate, AmendTime)

	SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
		, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- tran header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = ''IPA''
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN
	INNER JOIN ipi.IPName AS N 
		ON R.ID = N.ID
			AND H.IPNN = N.IPNN

	WHERE A.RowCode = ''MAN''
		AND A.HeaderCode = ''IPA''
		AND A.RowID BETWEEN @RowID1 AND @RowID2;		-- DO NOT USE A VARIABLE (due to Query Tuning)

	SET @RowCount = @@ROWCOUNT;
';

BEGIN TRY

-- loop

DECLARE @i AS int = 0;
DECLARE @N AS int = 10000;	-- row volume that enters the transaction (keep it small)
DECLARE @RowID1 AS bigint = 0;
DECLARE @RowID2 AS bigint = @N;
DECLARE @msg AS nvarchar(1000);
DECLARE @RowCount AS int;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop started...';

WHILE @RowID1 < 273810673
BEGIN

	EXEC sp_executesql @SQL
		, N'@RowID1 bigint, @RowID2 bigint, @RowCount int OUTPUT'
		, @RowID1 = @RowID1
		, @RowID2 = @RowID2
		, @RowCount = @RowCount OUTPUT;

	SET @msg = CAST(@i+1 AS nvarchar(10)) + '> ' + CAST(@RowCount AS nvarchar(10)) + ' rows';
	EXEC dbo.FastPrint @msg;

	SET @i = @i + 1;
	SET @RowID1 = @i * @N + 1;
	SET @RowID2 = (@i + 1) * @N;

END;

EXEC dbo.FastPrint '------------------------------------------------';
EXEC dbo.FastPrint 'Loop finished.';

END TRY
BEGIN CATCH
	THROW;
END CATCH;

	




	
	
	

	


