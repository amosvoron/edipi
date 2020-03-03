
/*
Object:			dbo.Tran_IPA
Description:	Process all IPA records for of a given transaction.

	IPA:IPA
	IPA:BDN
	IPA:STN
	IPA:NCN,ONN,MCN
	IPA:MAN
	IPA:TMA
	IPA:NTN
	IPA:NUN,INN
	IPA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Tran_IPA]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_10 @HeaderID;
	EXEC dbo.Query_20 @HeaderID;
	EXEC dbo.Query_30 @HeaderID;
	EXEC dbo.Query_40 @HeaderID;
	EXEC dbo.Query_50 @HeaderID;
	EXEC dbo.Query_60 @HeaderID;
	EXEC dbo.Query_70 @HeaderID;
	EXEC dbo.Query_80 @HeaderID;
	EXEC dbo.Query_90 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


