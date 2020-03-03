
/*
Object:			dbo.Tran_NPA
Description:	Process all NPA records for of a given transaction.

	NPA:NCN
	NPA:NCO+NCN
	NPA:NUN

*/

CREATE PROCEDURE [dbo].[Tran_NPA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_150 @HeaderID;
	EXEC dbo.Query_160 @HeaderID;
	EXEC dbo.Query_170 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


