
/*
Object:			dbo.CheckCollation
Description:	Checks if this database and tempdb has the same collation.
				If not, then the collation conflicts in the procedure dbo.Query_270 will occur.
				(Check the procedure for more info.)
*/

CREATE PROCEDURE [dbo].[CheckCollation]
AS 

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

