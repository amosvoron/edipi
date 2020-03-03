
/*
Object:			dbo.CloseSession
Description:	Closes the open session.
*/

CREATE PROCEDURE [dbo].[CloseSession]
AS 

-- get active session
DECLARE @SID AS int = dbo.GetSID();

-- close only valid session
IF dbo.IsSessionValid() = 1
BEGIN

	-- update session's EndTime
	UPDATE dbo.[Session]
	SET EndTime = GETDATE()
	WHERE [SID] = @SID;

END;

-- reset in-memory SID
EXEC [dbo].[SetContextData] 0;





GO


