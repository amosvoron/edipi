
/*
Object:			dbo.Parse_MCN
Description:	Parses all non-parsed MCN rows.
*/

CREATE PROCEDURE [dbo].[Parse_MCN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MCN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPBN)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 2)
	, SUBSTRING(Row, 123, 8)
	, SUBSTRING(Row, 131, 6)
	, SUBSTRING(Row, 137, 8)
	, SUBSTRING(Row, 145, 6)
	, SUBSTRING(Row, 151, 13)
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


