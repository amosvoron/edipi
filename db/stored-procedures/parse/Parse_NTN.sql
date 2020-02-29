
/*
Object:			dbo.Parse_NTN
Description:	Parses all non-parsed NTN rows.
*/

CREATE PROCEDURE [dbo].[Parse_NTN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NTN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, ValidFromDate, ValidToDate)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 4)
	, SUBSTRING(Row, 24, 8)
	, SUBSTRING(Row, 32, 20)
	, SUBSTRING(Row, 52, 8)
	, SUBSTRING(Row, 60, 8)
	, SUBSTRING(Row, 68, 8)
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


