USE [EDIPI]
GO
/****** Object:  StoredProcedure [dbo].[RemoveDuplicates]    Script Date: 5. 03. 2020 10:03:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.RemoveDuplicates
Description:		Safely removes IP name usage duplicates.
*/

ALTER PROCEDURE [dbo].[RemoveDuplicates]
AS   

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

EXEC dbo.FastPrint 'Duplicates of IPNameUsage removed.';


