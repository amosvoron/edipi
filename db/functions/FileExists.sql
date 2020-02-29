
/*
Object:				dbo.FileExists
Description:		Returns 1 if specified file within @path exists.
*/

CREATE FUNCTION [dbo].[FileExists](@path varchar(512))
RETURNS bit
AS
BEGIN
     DECLARE @result int;
     EXEC master.dbo.xp_fileexist @path, @result OUTPUT;
     RETURN CAST(@result as bit);
END;
GO


