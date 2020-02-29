
/*
Object:				dbo.IsProcessing
Description:		Returns 1 if the database state is PROCESSING.
*/

CREATE FUNCTION [dbo].[IsProcessing]()
RETURNS bit
AS
BEGIN
    RETURN (CASE WHEN dbo.GetDatabaseState() = 1 THEN 1 ELSE 0 END);
END;

GO
