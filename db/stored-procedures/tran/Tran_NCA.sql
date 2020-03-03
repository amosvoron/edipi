
/*
Object:			dbo.Tran_NCA
Description:	Process all NCA records for of a given transaction.

	NCA:NCN,ONN,MCN
	NCA:NUN,INN
	NCA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_NCA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_120 @HeaderID;
	EXEC dbo.Query_130 @HeaderID;
	EXEC dbo.Query_140 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


