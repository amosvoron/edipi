
/*
Object:			dbo.Parse_BDO
Description:	Parses all non-parsed BDO rows.
*/

CREATE PROCEDURE [dbo].[Parse_BDO]
	@Version char(5)
AS

SET NOCOUNT ON;

DECLARE @RowCode AS char(3) = 'BDO';
DECLARE @RowCount AS int;

EXEC dbo.ValidateRowLength @RowCode, @Version;

INSERT INTO dbo.Row
(RowID, HeaderID, RowCode, HeaderCode, TranSeq, RecordSeq, [Type]
	, BirthDate, DeathDate, BirthPlace, BirthState
	, TISN, TISNValidFrom, TISAN, TISANValidFrom
	, Sex, AmendDate, AmendTime)
SELECT 
	RowID
	, HeaderID
	, RowCode
	, HeaderCode
	, SUBSTRING(Row, 4, 8)
	, SUBSTRING(Row, 12, 8)
	, SUBSTRING(Row, 20, 1)
	, SUBSTRING(Row, 21, 8)
	, SUBSTRING(Row, 29, 8)
	, SUBSTRING(Row, 37, 30)
	, SUBSTRING(Row, 67, 30)
	, SUBSTRING(Row, 97, 4)
	, SUBSTRING(Row, 101, 8)
	, SUBSTRING(Row, 109, 20)
	, SUBSTRING(Row, 129, 8)
	, SUBSTRING(Row, 137, 1)
	, SUBSTRING(Row, 138, 8)
	, SUBSTRING(Row, 146, 6)
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


