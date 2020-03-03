
/*
Object:				dbo.ImportDiff
Description:		Imports all missing CONSECUTIVE differential files from the last import until today.
					-------------------------------------------------------------------------------------------------
Logic:				1. Loop while the procedure [dbo].[ImportFileDiff] returns 0 => IMPORT IS COMPLETED
					2. Terminate if next file does not exist:
					3. If RETURN VALUE = 1 => import was not needed (all files till today have already been imported)
					4. If RETURN VALUE = -1 => next file should exist, but does not exists.		
					-------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[ImportDiff]
AS

SET NOCOUNT ON;

DECLARE @ImportResult AS int = 0; 

BEGIN TRY;

	-- loop through all consecutive files
	WHILE @ImportResult = 0
	BEGIN

		EXEC @ImportResult = dbo.ImportFileDiff;

	END;

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Pri uvozu je prišlo do napake.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;



GO


