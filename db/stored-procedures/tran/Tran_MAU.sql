
/*
Object:			dbo.Tran_MAU
Description:	Process all MAU records for of a given transaction.

	MAU:MAO
	MAU:MAN
	MAU:TMA

*/

CREATE PROCEDURE [dbo].[Tran_MAU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_250 @HeaderID;
	EXEC dbo.Query_260 @HeaderID;
	EXEC dbo.Query_270_FORCED @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


