
/*
Object:			dbo.SetReady
Description:	Sets the database state as READY.
Note:			This procedure is called after the transaction has SUCCEEDED.
				Accessable from DWH database as well. 
*/

CREATE PROCEDURE [dbo].[SetReady]
AS

SET NOCOUNT ON;

-- set database state
UPDATE dbo.[Config] SET [DatabaseState] = 0;

GO


