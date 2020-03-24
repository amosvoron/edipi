
/*
Object:			dbo.RestoreMembershipByIP
Description:	Restores all membership data (IPMembership + IPMembershipTerritory)
				for a given IP from the first to the last membership transaction.
Note:			This procedure eliminates all current membership data for IP
				and imports data from the raw source (dbo.Raw). No file import is needed 
				unless the raw source is empty.				 
*/

CREATE PROCEDURE [dbo].[RestoreMembershipByIP]
	@ID int
AS

SET NOCOUNT ON;

DECLARE @IPBN char(13) = (SELECT IPBN FROM ipi.IP WHERE ID = @ID);

DECLARE @HeaderID bigint = -1;
BEGIN TRY

	BEGIN TRANSACTION;

	-- set processing status
	UPDATE [dbo].[Restore]
	SET IsProcessing = 1
	WHERE ID = @ID;

	-- remove membership data
	DELETE FROM ipi.IPMembership
	WHERE ID = @ID;

	-- begin cursor			
	DECLARE cur1 CURSOR LOCAL READ_ONLY FOR
		SELECT DISTINCT HeaderID
		FROM dbo.[Row]
		WHERE IPBN = @IPBN
			AND HeaderCode IN ('IPA', 'MAA', 'MAD', 'MAN', 'MAO', 'MAU')
		ORDER BY HeaderID;
	
	OPEN cur1;

	FETCH NEXT FROM cur1 INTO @HeaderID;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--EXEC dbo.FastPrint @HeaderID;

		-- IPA:MAN
		EXEC dbo.Query_50 @HeaderID;

		-- IPA:TMA
		EXEC dbo.Query_60 @HeaderID;

		-- MAA:MAN
		EXEC dbo.Query_100 @HeaderID;
			
		-- MAA:TMA
		EXEC dbo.Query_110 @HeaderID;

		-- MAD:MAO
		EXEC dbo.Query_380 @HeaderID;

		-- MAU:MAO
		EXEC dbo.Query_250 @HeaderID;

		-- MAU:MAN
		EXEC dbo.Query_260 @HeaderID;

		-- MAU:TMA
		EXEC dbo.Query_270 @HeaderID;

		FETCH NEXT FROM cur1 INTO @HeaderID;
	END	-- cursor

	CLOSE cur1;
	DEALLOCATE cur1;
	-- end of cursor

	-- update restore table
	UPDATE [dbo].[Restore]
	SET CanRestore = 0
		, IsProcessing = 0
	WHERE ID = @ID;

	COMMIT;

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 ROLLBACK;	
	DECLARE @e NVARCHAR(MAX) = 'ERROR: ' + ERROR_MESSAGE(); 
	INSERT INTO [dbo].[RestoreLog] (ID, HeaderID, [Message]) VALUES (@ID, @HeaderID, @e);
	EXEC dbo.FastPrint @e;

	-- set processing status
	UPDATE [dbo].[Restore]
	SET IsProcessing = 0
	WHERE ID = @ID;

	RETURN -1;    -- NOT OK
END CATCH;

RETURN 0;	-- OK


