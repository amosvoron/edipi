
/*
Object:			dbo.SetInterrupted
Description:	Sets the database state as INTERRUPTED and writes a log record.
Note:			This procedure is called after the transaction has FAILED. 
*/

CREATE PROCEDURE [dbo].[SetInterrupted]
	@SID int					-- SID where an error occured
	, @HeaderID bigint			-- transaction inside which an error occured
	, @Message nvarchar(MAX)	-- log (error) message
AS

SET NOCOUNT ON;

-- set database state
UPDATE dbo.[Config] SET [DatabaseState] = 2;

-- write a log
INSERT INTO [dbo].[Interrupted]
([SID], HeaderID, [Message])
VALUES (dbo.GetSID(), @HeaderID, @Message);

DECLARE @InterruptedID int = SCOPE_IDENTITY(); 

-- write log
EXEC dbo.WriteLog 0, 'Processing was interrupted.', @InterruptedID, 2;

GO


