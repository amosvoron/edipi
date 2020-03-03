
/*
Object:			dbo.ReprocessTrans
-------------------------------------------------------------------------------------------
				CURRENTLY ADJUSTED FOR NAME(USAGE) CORRECTIONS ONLY.
-------------------------------------------------------------------------------------------
Description:	Re-processes the transactions whose IsReprocess field is set to 1.

Note:			THIS PROCEDURE IS INTENDED FOR DATA CORRECTION. USE IT WITH CARE AND ONLY IN CASES WHEN DATA IS INCORRECT. 
				PRIOR TO USE MAKE SURE THAT THE NECESSARY CORRECTIONS OF THE RE-PROCESSING PROCEDURES HAVE BEEN DONE.
*/

ALTER PROCEDURE [dbo].[ReprocessTrans]
	@ID bigint
AS

SET NOCOUNT ON;

DISABLE TRIGGER ipi.IPName_RejectTrigger ON [ipi].[IPName];
DISABLE TRIGGER ipi.IPNameUsage_RejectTrigger ON [ipi].[IPNameUsage];

-- set default session 
DECLARE @SID AS int = 0;	-- re-processing SID

DECLARE @HeaderID AS bigint;
DECLARE @HeaderCode AS char(3);
DECLARE @msg AS nvarchar(MAX);

-- start try-catch block
BEGIN TRY
	BEGIN TRANSACTION;

	------------------------------------------------------------------------------------------
	-- Reset re-processing flag
	------------------------------------------------------------------------------------------
	
	UPDATE [dbo].[Transaction]
	SET [IsReprocess] = 0
	WHERE [IsReprocess] = 1;

	------------------------------------------------------------------------------------------
	-- Delete names
	------------------------------------------------------------------------------------------

	DELETE X
	FROM [ipi].[IPNameUsage] AS X
	INNER JOIN [ipi].[IPName] AS A ON X.NID = A.NID
	WHERE A.ID = @ID;
	EXEC dbo.FastPrint 'DELETE> ipi.IPNameUsage';

	DELETE X
	FROM [ipi].[IPName] AS X
	WHERE X.ID = @ID;
	EXEC dbo.FastPrint 'DELETE> ipi.IPName';

	------------------------------------------------------------------------------------------
	-- Mark re-processing transactions
	------------------------------------------------------------------------------------------

	DECLARE @IPBN AS char(13);
	SELECT @IPBN = IPBN
	FROM ipi.IP 
	WHERE ID = @ID;

	UPDATE X
	SET X.IsReprocess = 1
	FROM [dbo].[Transaction] AS X

	-- select only data of a given @ID
	WHERE EXISTS (
		SELECT NULL
		FROM (SELECT DISTINCT HeaderID
			FROM [dbo].[Row]
			WHERE IPBN = @IPBN
		) AS AA
		WHERE AA.HeaderID = X.HeaderID		
	)

	-- select only names data
	AND EXISTS (
		SELECT NULL
		FROM (SELECT DISTINCT HeaderCode
			FROM [dbo].[TransactionRecordInfo]
			WHERE [IsNameRecord] = 1
		) AS AA
		WHERE AA.HeaderCode = X.HeaderCode
	);

	-- check
	IF @@ROWCOUNT = 0
	BEGIN
		EXEC dbo.FastPrint 'No transaction has been specified for the re-processing.';
		ROLLBACK;
		RETURN;
	END;

	------------------------------------------------------------------------------------------
	-- Start the cursor processing.
	------------------------------------------------------------------------------------------

	EXEC dbo.FastPrint 'The processing started...';

	DECLARE _CUR CURSOR LOCAL FAST_FORWARD
	FOR
		SELECT HeaderID, HeaderCode
		FROM [dbo].[Transaction]
		WHERE IsReprocess = 1
		ORDER BY HeaderID
	OPEN _CUR;
	FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @msg = '#' + CAST(@HeaderID AS nvarchar(15)) + '>' + @HeaderCode;
		EXEC dbo.FastPrint @msg;	

		EXEC dbo.Query_40 @HeaderID;
		EXEC dbo.Query_80 @HeaderID;
		EXEC dbo.Query_90 @HeaderID;
		EXEC dbo.Query_120 @HeaderID;
		EXEC dbo.Query_130 @HeaderID;
		EXEC dbo.Query_140 @HeaderID;
		EXEC dbo.Query_150 @HeaderID;
		EXEC dbo.Query_160 @HeaderID;
		EXEC dbo.Query_170 @HeaderID;
		EXEC dbo.Query_190 @HeaderID;
		EXEC dbo.Query_200 @HeaderID;
		EXEC dbo.Query_280 @HeaderID;
		EXEC dbo.Query_290 @HeaderID;
		EXEC dbo.Query_300 @HeaderID;
		EXEC dbo.Query_310 @HeaderID;
		EXEC dbo.Query_311 @HeaderID;
		EXEC dbo.Query_320 @HeaderID;
		EXEC dbo.Query_321 @HeaderID;
		EXEC dbo.Query_330 @HeaderID;
		EXEC dbo.Query_340 @HeaderID;
		EXEC dbo.Query_350 @HeaderID;
		EXEC dbo.Query_360 @HeaderID;
		EXEC dbo.Query_370 @HeaderID;
		EXEC dbo.Query_390 @HeaderID;
		EXEC dbo.Query_400 @HeaderID;

		FETCH NEXT FROM _CUR INTO @HeaderID, @HeaderCode;

	END;
	CLOSE _CUR;
	DEALLOCATE _CUR;

	COMMIT TRANSACTION;

	EXEC dbo.FastPrint 'The processing completed.';

END TRY
BEGIN CATCH

	-- try rollback
	IF XACT_STATE() != 0 ROLLBACK;	

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	SET @msg = 'ERROR> ' + @e;
	EXEC dbo.FastPrint @msg;

	-- pass error to the caller
	RAISERROR(@e, @v, @s);

END CATCH;

ENABLE TRIGGER ipi.IPName_RejectTrigger ON [ipi].[IPName];
ENABLE TRIGGER ipi.IPNameUsage_RejectTrigger ON [ipi].[IPNameUsage];


GO


