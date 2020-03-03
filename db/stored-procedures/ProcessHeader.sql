
/*
Object:			dbo.ProcessHeader
Description:	A time consuming operation over dbo.RowHeader table split into smaller packages.
Expected speed:	1.000 rows/s (10s per package)
*/

CREATE PROCEDURE [dbo].[ProcessHeader]
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	UPDATE X
	SET
		HeaderID = A.HeaderID
		, HeaderCode = A.HeaderCode
	FROM dbo.RowHeader AS X
	CROSS APPLY (
		SELECT TOP(1) AA.RowID AS HeaderID, AA.RowCode AS HeaderCode
		FROM dbo.RowHeader AS AA
		INNER JOIN dbo.RowCodes AS BB ON AA.RowCode = BB.RowCode
		WHERE X.RowID >= AA.RowID
			AND BB.IsHeader = 1
		ORDER BY AA.RowID DESC
	) AS A
	WHERE X.RowID BETWEEN @RowID1 AND @RowID2;
';

BEGIN TRY

DECLARE @msg AS nvarchar(MAX);
DECLARE @N AS int = 10000;	-- row volume that enters the transaction (keep it small)
DECLARE @RowID1 AS bigint = (SELECT MIN(RowID) FROM dbo.RowHeader);
DECLARE @RowID2 AS bigint = @RowID1 + @N;

-- MAX RowID
DECLARE @EndRowID AS bigint = (SELECT MAX(RowID) FROM dbo.RowHeader);

-- number of packages
DECLARE @NumberOfPackages AS int = ROUND(CAST((@EndRowID - @RowID1) AS float)/10000, 0) + 1;

SET @msg = 'Updating HeaderID in ' + CAST(@NumberOfPackages AS nvarchar(10)) + ' package(s). Please wait...';
EXEC dbo.FastPrint '---------------------------------------------------------';
EXEC dbo.FastPrint @msg;

-- loop
WHILE @RowID1 < @EndRowID
BEGIN

	EXEC sp_executesql @SQL
		, N'@RowID1 bigint, @RowID2 bigint'
		, @RowID1 = @RowID1
		, @RowID2 = @RowID2;

	EXEC dbo.FastPrint @NumberOfPackages;

	SET @RowID1 = @RowID1 + @N + 1;
	SET @RowID2 = @RowID1 + @N;
	SET @NumberOfPackages = @NumberOfPackages - 1;

END;

EXEC dbo.FastPrint '---------------------------------------------------------';
EXEC dbo.FastPrint 'Update of HeaderID is finished.';

END TRY
BEGIN CATCH
	THROW;
END CATCH;


GO


