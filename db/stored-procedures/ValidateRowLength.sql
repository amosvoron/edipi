
/*
Object:			dbo.ValidateRowLength
Description:	Validates the row length in dbo.Import.
*/

CREATE PROCEDURE [dbo].[ValidateRowLength]
	@RowCode char(3),
	@Version char(5)	
AS

UPDATE dbo.Import
SET ErrorID = 2
WHERE RowCode = @RowCode
	AND [Version] = @Version
	AND LEN(Row) != (SELECT [Length] FROM dbo.RowCodes WHERE RowCode = @RowCode);


GO


