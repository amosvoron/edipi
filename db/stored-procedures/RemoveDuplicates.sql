
/*
Object:				dbo.RemoveDuplicates
Description:		Safely removes IP name usage duplicates.
*/

CREATE PROCEDURE [dbo].[RemoveDuplicates]
AS   

ALTER TABLE [ipi].[IPNameUsage] DISABLE TRIGGER [IPNameUsage_RejectTrigger];

-- NameUsage
WITH _Duplicates AS
(
	SELECT NID, CCCode, RoleCode
	FROM [ipi].[IPNameUsage]
	GROUP BY 
		[NID]
		, [CCCode]
		, [RoleCode]
	HAVING COUNT(*) > 1
)
DELETE X
FROM (
	SELECT B.NUID
		, ROW_NUMBER() OVER (
			PARTITION BY B.NID, B.CCCode, B.RoleCode
			ORDER BY B.[NUID] DESC 
		) AS RowN
	FROM _Duplicates AS A
	INNER JOIN [ipi].[IPNameUsage] AS B 
		ON A.NID = B.NID
		AND A.CCCode = B.CCCode
		AND A.RoleCode = B.RoleCode
) AS T
INNER JOIN [ipi].[IPNameUsage] AS X ON X.NUID = T.NUID
WHERE T.RowN > 1;

ALTER TABLE [ipi].[IPNameUsage] ENABLE TRIGGER [IPNameUsage_RejectTrigger];

EXEC dbo.FastPrint 'Duplicates of IPNameUsage removed.';


GO


