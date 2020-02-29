
/*
Object:			dbo.CheckNextFile
Description:	Checks the existance of the consecutive file.
				------------------------------------------------------------------
Note:			The consecutive file must exists in order to start the import.
				All files have to be imported in the CORRECT date order otherwise
				the database will get compromised.
				------------------------------------------------------------------
Logic:			
					1. Compute next file (name).
					2. Check whether the next file is needed:
						- NOT NULL:  next file is returned
						- NULL:		 next import is not needed
*/

ALTER FUNCTION [dbo].[ComputeNextFile]()
RETURNS nvarchar(128)
AS BEGIN

	DECLARE @NextDay AS datetime = DATEADD(DAY, 1, (SELECT RefDate FROM dbo.LastFile));

	-- check if next day is greater than today
	IF @NextDay >= CAST(CAST(GETDATE() AS DATE) AS datetime)
	BEGIN
		RETURN NULL;	-- import not needed
	END;

	DECLARE @NextFile AS nvarchar(128) = REPLACE(CONVERT(char(10), @NextDay, 126), '-', '') + '.IPI';
	RETURN @NextFile;	

END;





GO


