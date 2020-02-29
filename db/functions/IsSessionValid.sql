
/*
Object:			dbo.IsSessionValid
Description:	Returns 1 if sesion variable equals the last SID from dbo.Session table.
*/

CREATE FUNCTION [dbo].[IsSessionValid]()
RETURNS int

AS 
BEGIN 

	RETURN 
		CASE WHEN dbo.GetSID() = dbo.GetLastSID() THEN 1
		ELSE 0 END;

END

GO
