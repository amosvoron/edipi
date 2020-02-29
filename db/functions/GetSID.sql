
/*
Object:			dbo.GetSID
Description:	Gets current SID.
*/

CREATE FUNCTION [dbo].[GetSID] ()
RETURNS int

AS 
BEGIN 

	DECLARE @Data AS varchar(128) = dbo.GetContextData();
	DECLARE @SID AS int = 0;
	IF ISNUMERIC(@Data) = 1
	BEGIN
		SET @SID = CAST(@Data AS int)
	END;

	RETURN @SID;

END

GO
