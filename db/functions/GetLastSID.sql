
/*
Object:			dbo.GetLastSID
Description:	Gets last SID.
*/

CREATE FUNCTION [dbo].[GetLastSID] ()
RETURNS int
AS 
BEGIN 

	RETURN (SELECT TOP(1) [SID]
		FROM dbo.[Session]
		ORDER BY [SID] DESC);

END

GO
