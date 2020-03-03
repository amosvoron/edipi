
/*
Object:			dbo.Tran_NTU
Description:	Process all NTU records for of a given transaction.

	NTU:NTO
	NTU:NTN

*/

CREATE PROCEDURE [dbo].[Tran_NTU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_230 @HeaderID;
	EXEC dbo.Query_240 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


