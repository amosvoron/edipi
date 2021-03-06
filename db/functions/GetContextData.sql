
/*
Object:			dbo.GetContectData
Description:	Read data from CONTECT_INFO function as set by adm.SetContextData procedure
				and returns varchar(128) string.
*/

CREATE FUNCTION [dbo].[GetContextData] ()
RETURNS varchar(128)

AS 
BEGIN 

	DECLARE @Data As varchar(128);

	SELECT @Data =
			CASE WHEN A.Data = 0x0 THEN NULL ELSE  Cast(A.Data As varchar(128)) END
			FROM ( SELECT CONTEXT_INFO() As Data ) As A;
	
	RETURN @Data;

END



