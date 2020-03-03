
/*
Object:				dbo.Controller
Description:		Controls the progression of the import based on the existance of the next consecutive file.

Returns:			0 : Next file is found.
					1 : Import is not needed (any more).
				   -1 : FILE NOT FOUND. Import should be aborted.
*/

CREATE PROCEDURE [dbo].[Controller]
	@NextFile nvarchar(128) OUTPUT
AS

SET NOCOUNT ON;

DECLARE @msg AS nvarchar(MAX);

-- compute next file
SET @NextFile = dbo.ComputeNextFile();

-- if NULL return 1 (import not needed)
IF @NextFile IS NULL
BEGIN
	SET @msg = 'Database is up-to-date.';
	EXEC dbo.FastPrint @msg;
	RETURN 1;
END;

-- compose the full path
DECLARE @Path AS nvarchar(100) = (SELECT DiffPath FROM dbo.Config) + @NextFile;

-- check if file exists in the target directory 
IF [dbo].[FileExists](@Path) = 0
BEGIN
	RETURN -1;	-- FILE NOT FOUND
END;

-- Next consecutive file exists
RETURN 0;


GO


