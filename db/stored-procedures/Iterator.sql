
/*
Object:			dbo.Iterator
Description:	Iterates through all active parsers and parse body data of all non-parsed rows.
*/

CREATE PROCEDURE [dbo].[Iterator]
AS

BEGIN TRY;

	EXEC dbo.FastPrint '-------------------------------------------';
	EXEC dbo.FastPrint 'Parsing started...';

	DECLARE @RowCode AS char(3); 
	DECLARE @Version AS char(5); 
	DECLARE @sql AS nvarchar(1000);
	DECLARE CURSOR1 CURSOR LOCAL FAST_FORWARD 
	FOR
	  SELECT RowCode, [Version] FROM dbo.RowCodes
	  WHERE IsParserActive = 1
	OPEN CURSOR1;
	FETCH NEXT FROM CURSOR1 INTO @RowCode, @Version;
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @sql = N'EXEC dbo.Parse_' + @RowCode + ' ''' + @Version + '''';
		EXEC sp_executesql @sql;
	  FETCH NEXT FROM CURSOR1 INTO @RowCode, @Version;
	END; 
	CLOSE CURSOR1; 
	DEALLOCATE CURSOR1;

END TRY
BEGIN CATCH

	DECLARE @e NVARCHAR(MAX),@v INT,@s INT; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);

END CATCH;



GO


