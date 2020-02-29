
/*
Object:			dbo.Parse_STO
Description:	Parses all non-parsed STO rows.
*/

CREATE PROCEDURE [dbo].[Parse_STO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPBNRef
	, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
	, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 13)
	, SUBSTRING(Row, 33, 1)
	, SUBSTRING(Row, 34, 8)
	, SUBSTRING(Row, 42, 6)	
	, SUBSTRING(Row, 48, 8)
	, SUBSTRING(Row, 56, 6)
	, SUBSTRING(Row, 62, 8)
	, SUBSTRING(Row, 70, 6)	
FROM dbo.Import
WHERE RowCode = @RowCode
	--AND [Version] = @Version
	AND IsParsed = 0
	AND ErrorID = 0;	-- parse only valid rows

SET @RowCount = @@ROWCOUNT;

-- update parse status
EXEC dbo.UpdateParseStatus @RowCode, @Version;

-- output message
DECLARE @msg AS nvarchar(MAX) = @RowCode + ' parser finished: ' + CAST(@RowCount AS nvarchar(10));
EXEC dbo.FastPrint @msg;


GO


