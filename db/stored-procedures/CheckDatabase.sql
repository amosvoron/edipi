
/*
Object:			dbo.CheckDatabase
Description:	Checks if database is correctly initialized.
*/

CREATE PROCEDURE [dbo].[CheckDatabase]
AS 

BEGIN TRY

-- check dbo.Config
IF 1 <> (SELECT COUNT(*) FROM dbo.Config)
BEGIN
	RAISERROR('Database is not correctly initialized: The configuration table dbo.Config is empty.', 16, 1);
END;

-- check dbo.File
IF 0 = (SELECT COUNT(*) FROM dbo.[File])
BEGIN
	RAISERROR('Database is not correctly initialized: The file table is empty.', 16, 1);
END;

-- check collation
DECLARE @db_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX(DB_NAME(),'collation')));
DECLARE @tempdb_collation varchar(256) = 
	(SELECT CONVERT(varchar(256), DATABASEPROPERTYEX('tempdb','collation')));

IF @db_collation <> @tempdb_collation
BEGIN
	PRINT 'WARNING: The collations of this database and tempdb differ. 
         Please check the stored procedures dbo.Query_270 and 
		 follow the instructions in the header of the procedure.';
END;

END TRY
BEGIN CATCH
	THROW;
END CATCH

