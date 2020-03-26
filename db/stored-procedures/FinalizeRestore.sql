
/*
Object:			dbo.FinalizeRestore
Description:	Finalize restore by updating counters and restore statuses.
Note:			This procedure should be run manually if the restore procedure
				has been interrupted.		 
*/

CREATE PROCEDURE [dbo].[FinalizeRestore]
AS

-- update new membership counters
UPDATE X
SET X.[MembershipNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
LEFT OUTER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM [ipi].[IPMembership] AS AA
	INNER JOIN dbo.[Restore] AS CC ON AA.ID = CC.ID
	WHERE CC.ForProcessing = 1 AND CC.CanRestore = 0
	GROUP BY AA.ID
) AS A ON X.ID = A.ID
WHERE EXISTS (
	SELECT 1
	FROM dbo.[Restore] AS AA
	WHERE AA.ID = X.ID
		AND AA.ForProcessing = 1 AND AA.CanRestore = 0);

-- Update new territories counters
UPDATE X
SET X.[MembershipTerritoryNewCount] = ISNULL(A.N, 0)
FROM [dbo].[Restore] AS X
LEFT OUTER JOIN (
	SELECT AA.ID, COUNT(*) AS N
	FROM [ipi].[IPMembership] AS AA
	INNER JOIN [ipi].[IPMembershipTerritory] AS BB ON AA.MID = BB.MID
	INNER JOIN dbo.[Restore] AS CC ON AA.ID = CC.ID
	WHERE CC.ForProcessing = 1 AND CC.CanRestore = 0
	GROUP BY AA.ID
) AS A ON X.ID = A.ID
WHERE EXISTS (
	SELECT 1
	FROM dbo.[Restore] AS AA
	WHERE AA.ID = X.ID
		AND AA.ForProcessing = 1 AND AA.CanRestore = 0);

-- Update processing status
UPDATE [dbo].[Restore]
SET IsProcessing = 0
	, ForProcessing = 0
WHERE ForProcessing = 1;
