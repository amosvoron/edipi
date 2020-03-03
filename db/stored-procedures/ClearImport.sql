
/*
Object:				dbo.ClearImport
Description:		Clears dbo.Import table and prepare its RowID identifier for next import.
*/

CREATE PROCEDURE [dbo].[ClearImport]
AS

SET NOCOUNT ON;

-- clear
TRUNCATE TABLE dbo.Import;

-- set seed
DECLARE @LastRowID AS bigint;
SELECT @LastRowID = MAX(LastRowID) + 1 FROM dbo.[File];
DBCC CHECKIDENT ('dbo.Import', reseed, @LastRowID);

EXEC dbo.FastPrint '-----------------------------------------------';
EXEC dbo.FastPrint 'Import table has been cleared and reseeded.';

DECLARE @msg AS nvarchar(100) = 'Next RowID set to: ' + CAST(@LastRowID AS nvarchar(20));
EXEC dbo.FastPrint @msg;
EXEC dbo.FastPrint '-----------------------------------------------';

GO

