
/*
Object:			dbo.Query_60_Init
Description:	Initial insert of IPA:TMA records using loop.
				If the query is executed against the whole amount of source data 
				the transaction log grows beyond 50GBa and fills up all the disk space.
				The duration of the non-limited transaction is over 10 hours. 
				At the end the disk gets full and transaction is rolled back.
Expected time:	10h
Transaction:	IPA:TMA
*/

CREATE PROCEDURE [dbo].[Query_60_Init]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IPMembershipTerritory
	(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)

	SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
	FROM dbo.[Row] AS X

	-- find parent
	CROSS APPLY (
		SELECT TOP(1) AA.RowID, AA.MID
		FROM ipi.IPMembership AS AA
		INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
		WHERE AA.RowID < X.RowID
			AND BB.HeaderID = X.HeaderID	-- the same tran group
		ORDER BY AA.RowID DESC
	) AS A

	WHERE X.RowCode = ''TMA'' 
		AND X.HeaderCode = ''IPA''
		AND X.RowID BETWEEN @RowID1 AND @RowID2;		-- DO NOT USE A VARIABLE (due to Query Tuning)

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

	




	
	
	

	


GO


