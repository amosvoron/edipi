
/*
	Count statistics
*/

CREATE VIEW [dbo].[Statistics]
AS

SELECT 'dbo.Row' AS [Table], COUNT(*) AS 'Count' FROM [dbo].[Row]
UNION ALL
SELECT 'ipi.IP', COUNT(*) FROM [ipi].[IP]
UNION ALL
SELECT 'ipi.IPName', COUNT(*) FROM [ipi].[IPName]
UNION ALL
SELECT 'ipi.IPNameUsage', COUNT(*) FROM [ipi].[IPNameUsage]
UNION ALL
SELECT 'ipi.IPMembership', COUNT(*) FROM [ipi].[IPMembership]
UNION ALL
SELECT 'ipi.IPMembershipTerritory', COUNT(*) FROM [ipi].[IPMembershipTerritory]
UNION ALL
SELECT 'ipi.IPNationality', COUNT(*) FROM [ipi].[IPNationality]
UNION ALL
SELECT 'ipi.IPStatus', COUNT(*) FROM [ipi].[IPStatus]



GO


