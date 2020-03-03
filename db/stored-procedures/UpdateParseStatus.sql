
/*
Object:			dbo.UpdateParseStatus
Description:	Sets the IsParsed flag in dbo.Import to TRUE.
*/

CREATE PROCEDURE [dbo].[UpdateParseStatus]
	@RowCode char(3),
	@Version char(5)
AS

UPDATE dbo.Import
SET IsParsed = 1
WHERE RowCode = @RowCode
	AND IsParsed = 0
	AND ErrorID = 0;

GO


