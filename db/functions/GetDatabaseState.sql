
/*
Object:				dbo.GetDatabaseState
Description:		Returns the current state of the database.
*/

CREATE FUNCTION [dbo].[GetDatabaseState]()
RETURNS int
AS
BEGIN
    RETURN (
		SELECT TOP(1) [DatabaseState] 
		FROM [dbo].[Config]
	);
END;
GO


