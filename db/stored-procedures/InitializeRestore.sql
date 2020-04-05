
/*
Object:			dbo.InitializeRestore
Description:	Initialize restore by updating current membership counters.		 
*/

CREATE PROCEDURE [dbo].[InitializeRestore]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint 'Initialize restore...';

IF 0 = (
	SELECT COUNT(*) FROM dbo.[Restore] 
	WHERE ForProcessing = 1
)
BEGIN
	EXEC dbo.FastPrint 'No data to count. Initializer terminated.';
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
WHERE C.ForProcessing = 1;

CREATE NONCLUSTERED INDEX ix_#MEMBERSHIP ON #MEMBERSHIP (MID);

-- update new membership counters
UPDATE X
SET X.[MembershipOldCount] = ISNULL(A.N, 0)
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
SET X.[MembershipTerritoryOldCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
INNER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM #TERRITORY AS AA
	GROUP BY AA.ID
) AS A ON X.ID = A.ID;

EXEC dbo.FastPrint 'Territory counters updated.';
EXEC dbo.FastPrint 'Restore initialization finished.';
