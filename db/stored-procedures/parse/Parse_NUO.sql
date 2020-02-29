
/*
Object:			dbo.Parse_NUO
Description:	Parses all non-parsed NUO rows.
*/

CREATE PROCEDURE [dbo].[Parse_NUO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'NUO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, IPNN
	, CCCode, RoleCode)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 11)
	, SUBSTRING(Row, 31, 2)
	, SUBSTRING(Row, 33, 2)
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


