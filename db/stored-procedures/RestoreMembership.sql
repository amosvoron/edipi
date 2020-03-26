
/*
Object:			dbo.RestoreMembership
Description:	Restore membership data for a given N interested parties.		 
*/

CREATE PROCEDURE [dbo].[RestoreMembership]
	@N int = 10			-- how many IPs to restore
	, @ID int = NULL	-- if given only THIS particular ID is processed
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

	IF @ID IS NULL
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
		WHERE ID = @ID AND CanRestore = 1;
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
-- Store current membership data count in Restore table
--------------------------------------------------------

	UPDATE X
	SET X.[MembershipOldCount] = ISNULL(A.N, 0)
	FROM [dbo].[Restore] AS X
	LEFT OUTER JOIN (
		SELECT AA.ID, COUNT(*) AS N
		FROM [ipi].[IPMembership] AS AA
		INNER JOIN #IDS AS CC ON AA.ID = CC.ID
		GROUP BY AA.ID
	) AS A ON X.ID = A.ID
	WHERE EXISTS (
		SELECT 1
		FROM #IDS AS AA
		WHERE AA.ID = X.ID);

	UPDATE X
	SET X.[MembershipTerritoryOldCount] = ISNULL(A.N, 0)
	FROM [dbo].[Restore] AS X
	LEFT OUTER JOIN (
		SELECT AA.ID, COUNT(*) AS N
		FROM [ipi].[IPMembership] AS AA
		INNER JOIN [ipi].[IPMembershipTerritory] AS BB ON AA.MID = BB.MID
		INNER JOIN #IDS AS CC ON AA.ID = CC.ID
		GROUP BY AA.ID
	) AS A ON X.ID = A.ID
	WHERE EXISTS (
		SELECT 1
		FROM #IDS AS AA
		WHERE AA.ID = X.ID);

--------------------------------------------------------
-- Loop through IPs and run RestoreMembershipByIP
-- (for every IP)
--------------------------------------------------------

	EXEC dbo.FastPrint 'Processing started...';

	DECLARE @Ret int;
	DECLARE @k int = 1;

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
-- Finalizer
--------------------------------------------------------

EXEC FinalizeRestore;

EXEC dbo.FastPrint 'Membership restore completed.';
