
/*
	Return last file row
*/

CREATE VIEW [dbo].[LastFile] 
AS

SELECT TOP(1)
	FileID, [File], ImportDate, RefDate, FirstRowID, LastRowID, IsDiff, Note
FROM dbo.[File]
ORDER BY FileID DESC;

GO

