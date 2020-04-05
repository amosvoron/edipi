
/*
Object:			dbo.RestoreMembership
Description:	Restore membership data for a given N interested parties.		 
*/

CREATE PROCEDURE [dbo].[RestoreMembership]
	@N int = 10			-- how many IPs to restore
AS

SET NOCOUNT ON;

BEGIN TRY

	IF @N <= 0
	BEGIN
		PRINT 'N must be greater than zero.';
		RETURN;
	END;

--------------------------------------------------------
-- Select N IPs
--------------------------------------------------------

	CREATE TABLE #IDS (ID int NOT NULL PRIMARY KEY);

	-- get top @N which can be restored
	IF @N IS NOT NULL
	BEGIN
		INSERT INTO #IDS
		SELECT TOP(@N) ID
		FROM [dbo].[Restore] AS A
		WHERE CanRestore = 1
		ORDER BY ID;
	END
	ELSE BEGIN
		INSERT INTO #IDS
		SELECT ID
		FROM [dbo].[Restore] AS A
		WHERE ForProcessing = 1	
			AND CanRestore = 1
	END;

	IF @@ROWCOUNT = 0
	BEGIN
		PRINT 'No data to restore. Check CanRestore flag in [dbo].[Restore] table.';
		RETURN;
	END;

	-- update processing status
	UPDATE X
	SET X.ForProcessing = 1
	FROM [dbo].[Restore] AS X
	WHERE X.ID IN (SELECT ID FROM #IDS);

--------------------------------------------------------
-- Initialize restore by counting 
-- current membership data.
--------------------------------------------------------

	EXEC dbo.InitializeRestore;

--------------------------------------------------------
-- Disable reject triggers
--------------------------------------------------------

	ALTER TABLE [ipi].[IPMembership] DISABLE TRIGGER [IPMembership_RejectTrigger];
	ALTER TABLE [ipi].[IPMembership] DISABLE TRIGGER [IPMembership_DeleteBuffer];
	ALTER TABLE [ipi].[IPMembershipTerritory] DISABLE TRIGGER [IPMembershipTerritory_RejectTrigger];

--------------------------------------------------------
-- Loop through IPs and run RestoreMembershipByIP
-- (for every IP)
--------------------------------------------------------

	EXEC dbo.FastPrint 'Processing started...';

	DECLARE @Ret int;
	DECLARE @k int = 1;
	DECLARE @ID int;

	-- cursor			
	DECLARE cur1 CURSOR LOCAL READ_ONLY FOR
		SELECT ID FROM #IDS;	
	OPEN cur1;
	FETCH NEXT FROM cur1 INTO @ID;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--EXEC dbo.FastPrint @ID;

		EXEC [dbo].[RestoreMembershipByIP] @ID;

		IF @k % 1000 = 0 EXEC dbo.FastPrint @k;
		SET @k = @k + 1;

		FETCH NEXT FROM cur1 INTO @ID;
	END	
	CLOSE cur1;
	DEALLOCATE cur1;
	
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 ROLLBACK;	
	DECLARE @e NVARCHAR(MAX) = 'ERROR: ' + ERROR_MESSAGE(); 
	INSERT INTO [dbo].[RestoreLog] (ID, HeaderID, [Message]) 
		VALUES (ISNULL(@ID, -1), -2, @e);
	EXEC dbo.FastPrint @e;
END CATCH;

--------------------------------------------------------
-- Enable reject triggers
--------------------------------------------------------

ALTER TABLE [ipi].[IPMembership] ENABLE TRIGGER [IPMembership_RejectTrigger];
ALTER TABLE [ipi].[IPMembership] ENABLE TRIGGER [IPMembership_DeleteBuffer];
ALTER TABLE [ipi].[IPMembershipTerritory] ENABLE TRIGGER [IPMembershipTerritory_RejectTrigger];

--------------------------------------------------------
-- Finalizer
--------------------------------------------------------

EXEC FinalizeRestore;

EXEC dbo.FastPrint 'Membership restore completed.';
