
/*
Object:			dbo.Parse_MAO
Description:	Parses all non-parsed MAO rows.
*/

CREATE PROCEDURE [dbo].[Parse_MAO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'MAO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, SocietyCode
	, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime
	, ValidToDate, ValidToTime, SignDate, MemberShare, AmendDate
	, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 3)
	, SUBSTRING(Row, 23, 2)
	, SUBSTRING(Row, 25, 2)
	, SUBSTRING(Row, 27, 2)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 6)
	, SUBSTRING(Row, 43, 8)
	, SUBSTRING(Row, 51, 6)
	, SUBSTRING(Row, 57, 8)
	, SUBSTRING(Row, 65, 5)
	, SUBSTRING(Row, 70, 8)
	, SUBSTRING(Row, 78, 6)
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


