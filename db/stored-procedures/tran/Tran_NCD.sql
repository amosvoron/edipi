
/*
Object:			dbo.Tran_NCD
Description:	Process all NCD records for of a given transaction.

	NCD:MCO

*/

CREATE PROCEDURE [dbo].[Tran_NCD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_400 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


