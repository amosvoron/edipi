
/*
Object:			dbo.Finalize
Description:	Finalize the processing with setting the database state as READY.
Note:			This procedure is called AT THE END of the dbo.ProcessTrans processing.
				---------------------------
				Here the OK log is written.
				---------------------------
*/

CREATE PROCEDURE [dbo].[Finalize]
AS

SET NOCOUNT ON;

-- Sets the database state as READY.
--UPDATE dbo.[Config] SET [DatabaseState] = 0;
EXEC dbo.SetReady;

-- Output to console.
EXEC dbo.FastPrint '=============================================================';
EXEC dbo.FastPrint 'THE PROCESSING COMPLETED. DATABASE IS IN READY STATE.';
EXEC dbo.FastPrint '=============================================================';

-- Write log.
EXEC dbo.WriteLog 1, 'OK', NULL, 0;



GO


