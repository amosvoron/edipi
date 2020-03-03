
/*
Object:			dbo.FastPrint
Description:	Send message to output immediately (without waiting the execution to finish).
Author:			Miha Grobovšek
*/

CREATE PROCEDURE [dbo].[FastPrint]
	@text nvarchar(MAX) 
AS
BEGIN
	RAISERROR(@text,0,0) WITH NOWAIT;
END;

GO


