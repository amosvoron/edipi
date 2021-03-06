
/*
Object:			dbo.InitializeDatabase
Description:	Initialize the database by cleaning the target tables and preparing
				the configuration.
*/

CREATE PROCEDURE [dbo].[InitializeDatabase]
	@ImportDirectory varchar(128),	-- import directory with *.IPI files to import 
	@FirstFileName char(12)			-- name of the first IPI file to import
AS

SET NOCOUNT ON;

BEGIN TRY

-- Get path 
SET @ImportDirectory = IIF(SUBSTRING(@ImportDirectory, LEN(@ImportDirectory), 1) <> '\', 
	@ImportDirectory + '\', @ImportDirectory);
DECLARE @Path nvarchar(128) = @ImportDirectory + @FirstFileName;

---------------------------------------------------------------
-- Check if file exists
---------------------------------------------------------------

-- Check if @FirstFileName exists:
DECLARE @FileExists bit = [dbo].[FileExists](@Path);
IF @FileExists <> 1
BEGIN
	RAISERROR('File does not exist.', 16, 1);
END;

---------------------------------------------------------------
-- Check if file has correct name format
---------------------------------------------------------------

-- check length
IF LEN(@FirstFileName) <> 12
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

-- check date format
IF ISDATE(SUBSTRING(@FirstFileName, 1, 8)) = 0
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

-- check file extension
IF SUBSTRING(@FirstFileName, 10, 3) <> 'IPI'
BEGIN
	RAISERROR('Invalid file name. Should be in format yyyymmdd.IPI.', 16, 1);
END;

---------------------------------------------------------------
-- Clear tables
---------------------------------------------------------------

TRUNCATE TABLE [dbo].[Config];
TRUNCATE TABLE [dbo].[DatabaseLog];
TRUNCATE TABLE [dbo].[File];
TRUNCATE TABLE [dbo].[Import];
TRUNCATE TABLE [dbo].[Interrupted]; 
TRUNCATE TABLE [dbo].[Log];
TRUNCATE TABLE [dbo].[Row]; 
TRUNCATE TABLE [dbo].[RowHeader];
TRUNCATE TABLE [dbo].[Transaction];
DELETE FROM [dbo].[Session]; DBCC CHECKIDENT ('dbo.Session', reseed, 1);

TRUNCATE TABLE [ipi].[IPMembershipTerritory];
TRUNCATE TABLE [ipi].[IPNameUsage];
TRUNCATE TABLE [ipi].[IPNationality];
TRUNCATE TABLE [ipi].[IPStatus];
DELETE FROM [ipi].[IPName]; DBCC CHECKIDENT ('ipi.IPName', reseed, 1);
DELETE FROM [ipi].[IPMembership]; DBCC CHECKIDENT ('ipi.IPMembership', reseed, 1);
DELETE FROM [ipi].[IP]; DBCC CHECKIDENT ('ipi.IP', reseed, 1);

---------------------------------------------------------------
-- Initialize dbo.File and dbo.Config tables
---------------------------------------------------------------

DECLARE @PrevDate char(8) = 
	REPLACE(CONVERT(char(10), DATEADD(DAY, -1, SUBSTRING(@FirstFileName, 1, 8)), 127), '-', '');
DECLARE @PrevFile char(12) = CONCAT(@PrevDate, '.IPI');

INSERT INTO [dbo].[File]
([File], ImportDate, FirstRowID, LastRowID, IsDiff, Note)
VALUES (@PrevFile, GETDATE(), 0, 0, 0, 'Initial row to set RefDate');

INSERT INTO [dbo].[Config]
(DiffPath, DatabaseState, LastCommitedHeaderID)
VALUES (@ImportDirectory, 0, 0);

---------------------------------------------------------------
-- Check if db-tempdb collation matches
---------------------------------------------------------------

EXEC [dbo].[CheckCollation];

---------------------------------------------------------------

EXEC [dbo].[WriteLog] 1, 'The database is initialized.', NULL, 0;

PRINT '-------------------------------------------------';
PRINT 'Database initialization completed.';

END TRY
BEGIN CATCH

	-- Initialization failed:
	PRINT 'Database initialization failed. Please pass correct parameters and try again.';
	THROW;

END CATCH;
