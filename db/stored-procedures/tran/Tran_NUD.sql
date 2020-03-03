
/*
Object:			dbo.Tran_NUD
Description:	Process all NUD records for of a given transaction.

	NUD:INO,NUO,MUO,IMO

*/

CREATE PROCEDURE [dbo].[Tran_NUD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_390 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


