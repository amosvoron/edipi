
/*
Object:			dbo.Tran_NUA
Description:	Process all NUA records for of a given transaction.

	NUA:NUN,INN
	NUA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_NUA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_190 @HeaderID;
	EXEC dbo.Query_200 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


