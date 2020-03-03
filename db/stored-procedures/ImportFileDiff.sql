
/*
Object:				dbo.ImportFileDiff
Description:		Imports differential (day) files using BULK INSERT.
					-------------------------------------------------------------------------------
Note:				All CONSECUTIVE files in the IMPORT DIRECTORY are to be imported in SQL Server.
					-------------------------------------------------------------------------------
Return:				0 : Import completed with success.
					1 : Import was not needed.
				   -1 : FILE NOT FOUND. Import aborted.
*/

CREATE PROCEDURE [dbo].[ImportFileDiff]
AS

SET NOCOUNT ON;

DECLARE @ControllerResult AS int;
DECLARE @msg AS nvarchar(MAX);
DECLARE @NextFile AS nvarchar(128);
DECLARE @MinRowID AS bigint = ISNULL(
	(SELECT MAX(RowID) + 1 FROM dbo.Import), 
	(SELECT LastRowID + 1 FROM dbo.LastFile));

BEGIN TRY;

	-- get next file from the Controller & check return value
	EXEC @ControllerResult = dbo.Controller @NextFile OUTPUT;
	IF @ControllerResult != 0
	BEGIN
		RETURN @ControllerResult;	-- forward the Controller's return value
	END;

	-- compose the full path
	DECLARE @Path AS nvarchar(100) = (SELECT DiffPath FROM dbo.Config) + @NextFile;

	-- build SQL & exec
	DECLARE @sql AS nvarchar(MAX);
	SET @sql =
		N'BULK INSERT dbo.ToImport ' +
		N'FROM ''' + @Path + ''' ' +
		N'WITH ' + 
		N'( ' +
		N'KEEPIDENTITY, ' +
		N'ROWTERMINATOR = ''\n'' ' +
		N');';
	EXEC(@sql);

	SET @msg = 'File ' + @NextFile + ': import finished.';
	EXEC dbo.FastPrint @msg;

	-- get SID
	DECLARE @SID AS int = dbo.GetSID();

	DECLARE @FileID AS int;
	INSERT INTO dbo.[File] ([File], [SID])
	VALUES (@NextFile, @SID);

	SET @FileID = SCOPE_IDENTITY();

	-- set FileID to newly imported rows
	UPDATE dbo.Import
	SET FileID = @FileID
	WHERE FileID IS NULL;

	-- update RowID interval
	UPDATE dbo.[File] 
	SET 
		FirstRowID = @MinRowID
		, LastRowID = (SELECT MAX(RowID) FROM dbo.Import)
	WHERE FileID = @FileID;

	-- Import completed with success;
	RETURN 0;

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------';
	EXEC dbo.FastPrint 'Pri diferenčnem uvozu je prišlo do napake.';
	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	EXEC dbo.FastPrint '-----------------------------------------------';
	RETURN -2;

END CATCH;



GO


