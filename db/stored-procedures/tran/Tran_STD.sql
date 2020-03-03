
/*
Object:			dbo.Tran_STD
Description:	Process all STD records for of a given transaction.

	STD:STO
	STD:STN

*/

CREATE PROCEDURE [dbo].[Tran_STD]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_420 @HeaderID;
	EXEC dbo.Query_430 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


