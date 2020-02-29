
/*
Object:			dbo.Parse_ONN
Description:	Parses all non-parsed ONN rows.
*/

CREATE PROCEDURE [dbo].[Parse_ONN]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'ONN';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, Name, FirstName, NameType, CreationDate, CreationTime
	, AmendDate, AmendTime, IPNNRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 90)
	, SUBSTRING(Row, 121, 45)
	, SUBSTRING(Row, 166, 2)
	, SUBSTRING(Row, 168, 8)
	, SUBSTRING(Row, 176, 6)
	, SUBSTRING(Row, 182, 8)
	, SUBSTRING(Row, 190, 6)
	, SUBSTRING(Row, 196, 11)	
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


