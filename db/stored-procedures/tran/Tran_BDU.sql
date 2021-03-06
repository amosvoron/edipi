
/*
Object:			dbo.Tran_BDU
Description:	Process all BDU records for of a given transaction.

	BDU:BDN

*/

CREATE PROCEDURE [dbo].[Tran_BDU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_220 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


