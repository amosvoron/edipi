
/*
Object:			dbo.Process
Description:	Imports DIFFERENTIAL file(s) and processes all EDI IPI transactions.

ATTENTION:		DO NOT CALL THIS PROCEDURE FROM AN OUTER TRANSACTION!
				IN CASE OF A TRANSACTION FAILURE THE SESSION MANAGEMENT WILL FAIL AS WELL. 
				A DIFFERENCE BETWEEN THE SID-IN-MEMORY AND NON-EXISTING SID IN ROLLED BACK TABLE (dbo.Session) 
				WILL CAUSE THE FOREIGN KEY CONSTRAINT VIOLATION EXCEPTION.
*/

CREATE PROCEDURE [dbo].[Process]
	@SID int = NULL
AS

SET NOCOUNT ON;

DECLARE @ControllerResult AS int;
DECLARE @NextFile AS nvarchar(128);
DECLARE @Ret AS int;
DECLARE @LastMID bigint = (SELECT MAX(MID) FROM [ipi].[IPMembership]);

BEGIN TRY

	-- DO NOT START if the database is not in READY state.
	IF dbo.IsReady() = 0
	BEGIN
		EXEC dbo.FastPrint 'Database is not READY. The processing cannot be started.';
		RAISERROR('Database is not READY. The processing cannot be started.', 16, 1);
	END;

	-- Session management: 
	-----------------------------------------------------------------------------------------------------------------
	-- Session can be initially created by the processing program which calls dbo.CreateSession procedure.
	-- This program then passes the @SID to this procedure and that session is supposed to be valid.
	-- If this procedure is called directly by user then the session is not yet created and the global SID variable
	-- holds value 0 which is invalid session value. In that case the session has to be (re)created.
	-----------------------------------------------------------------------------------------------------------------
	IF @SID IS NULL
	BEGIN
		EXEC dbo.ClearSession;	-- if called directly clear the in-memory session storage, just to be sure it is being cleared
	END;
	EXEC dbo.TryRecreateSession @SID;

	-- clear & reseed import table
	EXEC dbo.Initialize;

	-- check if import is feasible
	EXEC @ControllerResult = dbo.Controller @NextFile OUTPUT;
	IF @ControllerResult != 0
	BEGIN
		-- write log: import aborted
		EXEC dbo.SkipImport;
		GOTO Processing;
	END;

	-- execute differential import (at least one file should be imported)
	EXEC dbo.ImportDiff;

	-- parse imported data and store it into dbo.Row table as a raw data
	EXEC dbo.[Parse];

Processing:
	-- process all non-processed transactions and finalize the session.
	EXEC @Ret = dbo.ProcessTrans;

	-- All transactions already committed:
	IF @Ret = -1
	BEGIN
		GOTO Finalize;
	END;

	-- remove duplicates (only if any new transaction)
	EXEC dbo.RemoveDuplicates;

Finalize:
	-- finalize processing
	EXEC dbo.Finalize;

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;

	EXEC dbo.FastPrint '=============================================================';
	EXEC dbo.FastPrint 'THE PROCESSING FAILED. DATABASE IS IN NON-READY STATE.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	EXEC dbo.FastPrint '=============================================================';

	-- try recreate session (to be sure that logging will not fail)
	EXEC dbo.TryRecreateSession;

	-- write log
	EXEC dbo.WriteLog 0, @e, NULL, NULL;

	-- re-enable reject triggers
	EXEC dbo.EnableRejectTriggers;

END CATCH;

-- Close the session.
EXEC dbo.CloseSession;


GO


