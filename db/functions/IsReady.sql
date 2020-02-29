
/*
Object:				dbo.IsReady
Description:		Returns 1 if the database state is READY.
*/

CREATE FUNCTION [dbo].[IsReady]()
RETURNS bit
AS
BEGIN
    RETURN (CASE WHEN dbo.GetDatabaseState() = 0 THEN 1 ELSE 0 END);
END;

GO
