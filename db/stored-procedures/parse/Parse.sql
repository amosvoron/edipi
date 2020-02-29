
/*
Object:			dbo.Parse
Description:	Parses all non-parsed header rows.
*/

CREATE PROCEDURE [dbo].[Parse]
AS

SET NOCOUNT ON;

BEGIN TRY;

DECLARE @msg AS nvarchar(MAX);

EXEC dbo.FastPrint '-------------------------------------------';

------------------------------------------------------------------------------------
-- Parse 3-char RowCode.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET RowCode = SUBSTRING(Row, 1, 3)
WHERE IsParsed = 0;

EXEC dbo.FastPrint 'RowCodes have been parsed.';

------------------------------------------------------------------------------------
-- File content validation (by parsing the RowCodes).
-- Note: IF A FILE CONTENT IS NOT VALID IT IS VERY LIKELY
-- THAT ROW CODE WILL NOT GET PARSED CORRECTLY.
------------------------------------------------------------------------------------

IF EXISTS (
	SELECT NULL
	FROM dbo.Import AS A
	LEFT OUTER JOIN [dbo].[RowCodes] AS B ON A.RowCode = B.RowCode
	WHERE B.RowCode IS NULL
)
BEGIN
	EXEC dbo.FastPrint 'Invalid file content. RowCode does not exist.';
	RAISERROR('Invalid file content. RowCode does not exist.', 16, 1);
END;

------------------------------------------------------------------------------------
-- Header validation.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET ErrorID = 1
WHERE RowCode = 'GRH'
	AND IsParsed = 0
	AND LEN(Row) != 16;

IF @@ROWCOUNT = 0
BEGIN
	EXEC dbo.FastPrint 'Import header is valid.';
END
ELSE BEGIN
	EXEC dbo.FastPrint 'Invalid import header (GRH).';
	RAISERROR('Invalid import header (GRH).', 16, 1);
END;

------------------------------------------------------------------------------------
-- Set header parse status.
------------------------------------------------------------------------------------

UPDATE dbo.Import
SET IsParsed = 1
WHERE RowCode = 'GRH'
	AND IsParsed = 0
	AND ErrorID = 0;

------------------------------------------------------------------------------------
-- Iterate & parse.
------------------------------------------------------------------------------------

EXEC dbo.Iterator;

EXEC dbo.FastPrint 'Parsing completed.';

------------------------------------------------------------------------------------
-- Check if all imported rows have been parsed.
------------------------------------------------------------------------------------

DECLARE @UnparsedRowCode AS char(3);
SELECT TOP(1) @UnparsedRowCode = RowCode FROM [dbo].[UnparsedRowCodes];
IF @UnparsedRowCode IS NOT NULL
BEGIN
	SET @msg = 'ATTENTION: Not all rows have been parsed (' + @UnparsedRowCode + ').';
	EXEC dbo.FastPrint @msg;
	RAISERROR(@msg, 16, 1);
END;

------------------------------------------------------------------------------------
-- Clear & fill row header temp table
-- Note: we use dbo.RowHeader table instead of dbo.Import becuase of its small size.
-------------------------------------------------------------------------------------

TRUNCATE TABLE [dbo].[RowHeader];

INSERT INTO [dbo].[RowHeader]
(RowID, RowCode)
SELECT RowID, RowCode
FROM dbo.Import;

------------------------------------------------------------------------------------
-- Process header (time consuming operation).
------------------------------------------------------------------------------------

EXEC [dbo].[ProcessHeader];

------------------------------------------------------------------------------------
-- The ONLY update on table dbo.Row.
------------------------------------------------------------------------------------

UPDATE X
SET 
	HeaderCode = A.HeaderCode,
	HeaderID = A.HeaderID
FROM dbo.[Row] AS X

-- since RowHeader table contains only diff data
-- this join will exclude all already-processed rows
-- (keeping only newly imported rows for update)
INNER JOIN dbo.RowHeader AS A ON X.RowID = A.RowID;

EXEC dbo.FastPrint 'Header in dbo.Row table (dbo.Row) UPDATED.';

------------------------------------------------------------------------------------
-- Add new transactions.
------------------------------------------------------------------------------------

DECLARE @SID AS int = dbo.GetSID();

INSERT INTO [dbo].[Transaction]
([SID], HeaderCode, HeaderID)
SELECT DISTINCT @SID, HeaderCode, HeaderID
FROM [dbo].[RowHeader]
WHERE HeaderCode IS NOT NULL;

SET @msg = 'New transactions have been added (' + CAST(@@ROWCOUNT AS nvarchar(10)) + ').';
EXEC dbo.FastPrint @msg;

------------------------------------------------------------------------------------
-- Add new row codes. (Not likely.)
------------------------------------------------------------------------------------

WITH _Codes AS
(
	SELECT DISTINCT RowCode FROM dbo.Import
)
INSERT INTO dbo.RowCodes (RowCode, Note)
SELECT RowCode, 'new'
FROM _Codes AS A
WHERE NOT EXISTS (
	SELECT AA.RowCode 
	FROM dbo.RowCodes AS AA
	WHERE AA.RowCode = A.RowCode
);

IF @@ROWCOUNT > 0
BEGIN
	EXEC dbo.FastPrint 'New ROW CODES has been added.';
END;

EXEC dbo.FastPrint '-------------------------------------------';
EXEC dbo.FastPrint 'Imported data has been successfully parsed.';

-----------

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Parsing has failed.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;


GO


