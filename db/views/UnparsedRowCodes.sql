
/*
	Return unparsed rows from dbo.Import
*/

CREATE VIEW [dbo].[UnparsedRowCodes] 
AS

SELECT DISTINCT A.RowCode
	, CASE WHEN B.RowCode IS NULL THEN 'NO PARSER' 
		ELSE CASE WHEN B.IsParserActive = 0 THEN 'INACTIVE PARSER'
			ELSE 'NOT PARSED' END END AS Reason
FROM dbo.Import AS A
LEFT OUTER JOIN dbo.RowCodes AS B ON A.RowCode = B.RowCode
WHERE A.IsParsed = 0
	AND B.[IsGroupHeader] = 0;

GO
