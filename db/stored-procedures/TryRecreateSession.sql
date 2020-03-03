
/*
Object:			dbo.TryRecreateSession
Description:	Checks if SID exists in dbo.Session table and if not SID the session is recreated:
					- new session record is inserted
					- the SID variable is assigned with the new value
Note:			In case of a ROLLBACK in the dbo.ProcessTrans procedure the session is removed 
				from the dbo.Session table but the memory variable remains intact. This procedure helps 
				to reestablish the initial match between the table and the variable value. 
*/

CREATE PROCEDURE [dbo].[TryRecreateSession]
	@SID AS int = NULL	-- if given then the validation will be executed against this value
						-- and not against the SID value from global CONTEXT_DATA variable
AS

SET NOCOUNT ON;

-- SID management
SET @SID = ISNULL(@SID, dbo.GetSID());
EXEC [dbo].[SetContextData] @SID;

IF dbo.IsSessionValid() = 0
BEGIN

	INSERT INTO [dbo].[Session] DEFAULT VALUES;
	SET @SID = SCOPE_IDENTITY();	

	DECLARE @msg AS nvarchar(1000) = 'New session ' + CAST(@SID AS nvarchar(10)) + ' is created.';
	EXEC dbo.FastPrint @msg;

END;

-- restore the global variable
EXEC [dbo].[SetContextData] @SID;



GO


