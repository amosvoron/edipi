
/*
Object:			dbo.SetContectData
Description:	Sets CONTEXT_INFO variable associated with the current session or connection.
*/

CREATE PROCEDURE [dbo].[SetContextData]
	@DATA As varchar(128)

AS 

DECLARE  @CONTEXT_INFO varbinary(128);

SELECT  @CONTEXT_INFO = 
	Cast(Cast(@DATA As varchar(127)) +
	Space(128) As binary(128));			-- add WHITESPACE up to fill up 128 bytes
	
SET CONTEXT_INFO @CONTEXT_INFO;


GO


