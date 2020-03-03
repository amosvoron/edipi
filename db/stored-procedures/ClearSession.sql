
/*
Object:			dbo.ClearSession
Description:	Clears the global session variable.
*/

CREATE PROCEDURE [dbo].[ClearSession]
AS 

-- reset in-memory SID
EXEC [dbo].[SetContextData] 0;


GO


