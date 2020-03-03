
/*
Object:			dbo.Tran_MAA
Description:	Process all MAA records for of a given transaction.

	MAA:MAN
	MAA:TMA

*/

CREATE PROCEDURE [dbo].[Tran_MAA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_100 @HeaderID;
	EXEC dbo.Query_110 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


