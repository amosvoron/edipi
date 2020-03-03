
/*
Object:			dbo.Tran_MAD
Description:	Process all MAD records for of a given transaction.

	MAD:MAO

*/

CREATE PROCEDURE [dbo].[Tran_MAD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_380 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


