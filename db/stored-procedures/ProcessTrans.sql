
/*
Object:			dbo.ProcessTrans
Description:	Processes all non-processed transactions from the last processed transaction on.

Note:			DO NOT CALL THIS PROCEDURE FROM AN OUTER TRANSACTION!
				IN CASE OF A TRANSACTION FAILURE THE SESSION MANAGEMENT WILL FAIL AS WELL. 
				A DIFFERENCE BETWEEN THE SID-IN-MEMORY AND NON-EXISTING SID IN ROLLED BACK TABLE (dbo.Session) 
				WILL CAUSE THE FOREIGN KEY CONSTRAINT VIOLATION EXCEPTION.
*/

CREATE PROCEDURE [dbo].[ProcessTrans]
	@EndHeaderID bigint = NULL				-- if NULL then upper limit is not defined (process ALL)
	, @DatabaseInProcessingState bit = 0	-- if 1 then this procedure has to continue with unprocessing transactions using the new SID (!!!)
AS

SET NOCOUNT ON;

-- get session variable
DECLARE @SID AS int = dbo.GetSID();

-- Prevent calling this procedure directly by user.
-- It should be called ONLY by the main dbo.Process procedure.
IF dbo.IsSessionValid() = 0
BEGIN

	-- throw exception 
	--    if database is not in PROCESSING state and this procedure is not called by dbo.ProcessUnfinished -
	--    which executes this procedure by @DatabaseInProcessingState = 1 param.
	IF @DatabaseInProcessingState = 0 OR dbo.IsProcessing() = 0
	BEGIN
		IF XACT_STATE() != 0 ROLLBACK;	
		RAISERROR('It was not intended to call the procedure dbo.ProcessTrans directly. Please use dbo.Process procedure instead.', 16, 1);
		RETURN;
	END;

	-- here we continue with the procerssing of the unfinished transactions
	-- Note: We use the last SID
	IF ISNULL(@SID, 0) = 0
	BEGIN

		-- create new SID
		EXEC [dbo].[TryRecreateSession];

	END;

END;

-- get session variable
--DECLARE @SID AS int = dbo.GetSID();

DECLARE @HeaderID AS bigint;
DECLARE @HeaderCode AS char(3);
DECLARE @msg AS nvarchar(MAX);
DECLARE @SQL AS nvarchar(MAX);

-- start try-catch block
BEGIN TRY

	------------------------------------------------------------------------------------------
	-- Gets and validates the beginning transaction.
	------------------------------------------------------------------------------------------

	DECLARE @BeginHeaderID AS bigint = [dbo].[FirstNonProcessedHeaderID]();

	-- check if there is any beginning transaction
	IF @BeginHeaderID IS NULL
	BEGIN
		EXEC dbo.FastPrint 'Attention: All transactions are commited. The processing will not start.';
		RETURN -1;
	END;

	------------------------------------------------------------------------------------------
	-- Start the cursor processing.
	------------------------------------------------------------------------------------------

	EXEC dbo.FastPrint 'The processing started...';

	DECLARE _CUR CURSOR LOCAL FAST_FORWARD
	FOR
		SELECT HeaderID, HeaderCode
		FROM [dbo].[Transaction]
		WHERE HeaderID BETWEEN @BeginHeaderID AND ISNULL(@EndHeaderID, 1000000000000000000);
	OPEN _CUR;
	FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- Check if transaction is active. If not throw an exception. 
		-- It is important to understand that THE PROCESSING AS A WHOLE IS VALID ONLY
		-- IF ALL UNCOMMITED (ACTIVE) TRANSACTIONS ARE CONSECUTIVE (CHAINED) ONES UNTIL THE LAST TRANSACTION
		-- IN THE CHAIN AND THAT THERE IS NO INACTIVE GAPS (STATUS 2) IN THE TRANSACTION CHAIN.
		---------------------------------------------------------------------------------------------------------
		-- EVERY TRANSACTION FETCHED BY THIS CURSOR IS ANTICIPATED TO BE AN ACTIVE TRANSACTION.
		---------------------------------------------------------------------------------------------------------

		IF dbo.IsActive(@HeaderID) = 0
		BEGIN
			SET @msg = 'Transaction #' + CAST(ISNULL(@HeaderID, 0) AS nvarchar(15)) + ' is invalid (inactive).';
			RAISERROR(@msg, 16, 1);
			RETURN;
		END;
 
 		---------------------------------------------------------------------------------------------------------
		-- Mark the transaction as PROCESSING.
		---------------------------------------------------------------------------------------------------------

		EXEC dbo.SetTranAsProcessing @HeaderID;

 		---------------------------------------------------------------------------------------------------------
		-- Notify the console.
		---------------------------------------------------------------------------------------------------------

		SET @msg = '#' + CAST(@HeaderID AS nvarchar(15)) + '>' + @HeaderCode;
		EXEC dbo.FastPrint @msg;	

		---------------------------------------------------------------------------------------------------------
		-- Execute the transaction procedure.
		---------------------------------------------------------------------------------------------------------

		BEGIN TRANSACTION;

		SET @SQL = N'EXEC dbo.Tran_' + @HeaderCode + ' @HeaderID;';
		EXEC sp_executesql @SQL
			, N'@HeaderID bigint'
			, @HeaderID = @HeaderID;

		COMMIT;

 		---------------------------------------------------------------------------------------------------------
		-- Mark the transaction as COMMITED.
		---------------------------------------------------------------------------------------------------------

		EXEC dbo.SetTranAsCommited @HeaderID;
		
		---------------------------------------------------------------------------------------------------------

		FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;

	END;
	CLOSE _CUR;
	DEALLOCATE _CUR;

	EXEC dbo.FastPrint 'The processing completed.';

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;	

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	SET @msg = 'ERROR> ' + @e;
	EXEC dbo.FastPrint @msg;

	-- try recreate session (if called inside OUTER transaction)
	EXEC dbo.TryRecreateSession;

	-- handle process interuption
	EXEC dbo.SetInterrupted @SID, @HeaderID, @e;

	-- set transaction as failed
	EXEC [dbo].[SetTranAsFailed] @HeaderID;

	-- pass error to the caller
	RAISERROR(@e, @v, @s);

END CATCH;


GO


