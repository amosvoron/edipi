
/*
Object:			dbo.Query_10
Transaction:	IPA:IPA
*/

CREATE PROCEDURE [dbo].[Query_10]
	@HeaderID AS bigint
AS

SET NOCOUNT ON;

DECLARE @SQL AS nvarchar(MAX) = N'

	INSERT INTO ipi.IP
	(RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex)
	SELECT RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex
	FROM dbo.[Row]
	WHERE 
		HeaderID = @HeaderID
		AND HeaderCode = ''IPA''
		AND RowCode = ''IPA'';	
';

EXEC sp_executesql @SQL
	, N'@HeaderID bigint'
	, @HeaderID = @HeaderID;


GO


