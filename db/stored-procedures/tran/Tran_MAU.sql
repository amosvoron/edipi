USE [EDIPI]
GO
/****** Object:  StoredProcedure [dbo].[Tran_MAU]    Script Date: 4. 03. 2020 20:37:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:			dbo.Tran_MAU
Description:	Process all MAU records for of a given transaction.

	MAU:MAO
	MAU:MAN
	MAU:TMA

*/

ALTER PROCEDURE [dbo].[Tran_MAU]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

BEGIN TRY

	EXEC dbo.Query_250 @HeaderID;
	EXEC dbo.Query_260 @HeaderID;
	EXEC dbo.Query_TMA @HeaderID, 'MAU'		-- MAU:TMA	
	--EXEC dbo.Query_270 @HeaderID;

END TRY
BEGIN CATCH

	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;
