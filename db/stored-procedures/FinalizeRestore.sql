
/*
Object:			dbo.FinalizeRestore
Description:	Finalize restore by updating counters and restore statuses.
Note:			This procedure should be run manually if the restore procedure
				has been interrupted.		 
*/

CREATE PROCEDURE [dbo].[FinalizeRestore]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint 'Finalize restore...';

IF 0 = (
	SELECT COUNT(*) FROM dbo.[Restore] 
	WHERE ForProcessing = 1 AND CanRestore = 0
)
BEGIN
	EXEC dbo.FastPrint 'No data to count. Finalizer terminated.';
	RETURN;
END;

CREATE TABLE #MEMBERSHIP (
	MID bigint NOT NULL PRIMARY KEY,
	ID int NOT NULL
);

INSERT INTO #MEMBERSHIP (MID, ID)
SELECT A.MID, A.ID 
FROM [ipi].[IPMembership] AS A
INNER JOIN dbo.[Restore] AS C ON A.ID = C.ID
WHERE C.ForProcessing = 1 AND C.CanRestore = 0;

CREATE NONCLUSTERED INDEX ix_#MEMBERSHIP ON #MEMBERSHIP (MID);

-- update new membership counters
UPDATE X
SET X.[MembershipNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #MEMBERSHIP AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

CREATE TABLE #TERRITORY (
	ID int NOT NULL
);

EXEC dbo.FastPrint 'Membership counters updated.';

INSERT INTO #TERRITORY
SELECT A.ID 
FROM #MEMBERSHIP AS A
INNER JOIN [ipi].[IPMembershipTerritory] AS B ON A.MID = B.MID;

CREATE NONCLUSTERED INDEX ix_#TERRITORY ON #TERRITORY (ID);

-- update new territory counters
UPDATE X
SET X.[MembershipTerritoryNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #TERRITORY AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

EXEC dbo.FastPrint 'Territory counters updated.';

-- Update processing status
UPDATE [dbo].[Restore]
SET ForProcessing = 0
WHERE ForProcessing = 1 
	AND CanRestore = 0;

UPDATE [dbo].[Restore]
SET IsProcessing = 0
WHERE IsProcessing = 1;

EXEC dbo.FastPrint 'Statuses updated.';
EXEC dbo.FastPrint '-------------------------';
EXEC dbo.FastPrint 'Restore terminated.';
