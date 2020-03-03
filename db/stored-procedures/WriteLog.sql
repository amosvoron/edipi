
/*
Object:			dbo.WriteLog
Description:	Inserts the log record (at the end of processing).
*/

CREATE PROCEDURE [dbo].[WriteLog]
	@IsOK bit
	, @Message AS nvarchar(MAX)
	, @InterruptedID AS int
	, @DatabaseState AS int
AS 

SET NOCOUNT ON;

-- get SID
DECLARE @SID AS int = dbo.GetSID();

-- if @DatabaseState IS NULL => fetch it from the Config table
IF @DatabaseState IS NULL
BEGIN
	SELECT TOP(1) @DatabaseState = DatabaseState
	FROM dbo.[Config];
END;

INSERT INTO [dbo].[Log] ([SID], [IsOK], [Message], [InterruptedID], [DatabaseState])
VALUES (@SID, @IsOK, @Message, @InterruptedID, @DatabaseState);

GO


