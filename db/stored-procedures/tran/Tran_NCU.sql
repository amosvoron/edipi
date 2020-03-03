
/*
Object:			dbo.Tran_NCU
Description:	Process all NCU records for of a given transaction.

	NCU:NCO+NCN
	NCU:NCO
	NCU:NCN
	NCU:MCO
	NCU:MCN
	NCU:ONO
	NCU:ONN
	NCU:MCO,ONO+NCN
	NCU:IMO
	NCU:IMN
	NCU:INO
	NCU:INN

*/

CREATE PROCEDURE [dbo].[Tran_NCU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_280 @HeaderID;
	EXEC dbo.Query_290 @HeaderID;
	EXEC dbo.Query_300 @HeaderID;
	EXEC dbo.Query_310 @HeaderID;
	EXEC dbo.Query_311 @HeaderID;
	EXEC dbo.Query_320 @HeaderID;
	EXEC dbo.Query_321 @HeaderID;
	EXEC dbo.Query_330 @HeaderID;
	EXEC dbo.Query_340 @HeaderID;
	EXEC dbo.Query_350 @HeaderID;
	EXEC dbo.Query_360 @HeaderID;
	EXEC dbo.Query_370 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


