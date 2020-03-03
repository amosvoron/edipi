USE [EDIPI]

/*
Object:			dbo.SkipImport
Description:	Skip the import if database is up-to-date or the consecutive file is missing.
Note:			---------------------------------------------------------------
				Only logging is performed by this procedure. No other action.
				---------------------------------------------------------------
				This procedure is called in the main procedure after the initial controller check fails.
*/

CREATE PROCEDURE [dbo].[SkipImport]
AS

SET NOCOUNT ON;

DECLARE @msg AS nvarchar(500)
DECLARE @FileNotFound AS nvarchar(128) = dbo.ComputeNextFile();

-- database is up-to-date
IF @FileNotFound IS NULL
BEGIN
	SET @msg = 'Database is up-to-date.';
	EXEC dbo.WriteLog 1, @msg, NULL, 0;
END
-- file not found
ELSE BEGIN
	SET @msg = 'File ' + @FileNotFound + ' not found. Import skipped.';
	EXEC dbo.FastPrint @msg;
	EXEC dbo.WriteLog 0, @msg, NULL, 0;
END;




GO


