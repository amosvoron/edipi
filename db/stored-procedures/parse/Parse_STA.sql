
/*
Object:			dbo.Parse_STA
Description:	Parses all non-parsed STA rows.
*/

CREATE PROCEDURE [dbo].[Parse_STA]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'STA';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, TranDate
	, TranTime, SocietyCode, SocietyName, IPBN, StatusCode
	, IPNN, NameType, IPBNRef, StatusCodeRef, IPNNRef
	, NameTypeRef)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 8)
	, SUBSTRING(Row, 28, 6)
	, SUBSTRING(Row, 34, 3)
	, SUBSTRING(Row, 37, 20)
	, SUBSTRING(Row, 57, 13)
	, SUBSTRING(Row, 70, 1)
	, SUBSTRING(Row, 71, 11)
	, SUBSTRING(Row, 82, 2)
	, SUBSTRING(Row, 84, 13)
	, SUBSTRING(Row, 97, 1)
	, SUBSTRING(Row, 98, 11)
	, SUBSTRING(Row, 109, 2)
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


