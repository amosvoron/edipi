
/*
Object:			dbo.SetTranAsProcessing
Description:	Sets the transaction as commited.
Note:			This procedure is called before the PROCESSING of the transaction starts. 
*/

CREATE PROCEDURE [dbo].[SetTranAsProcessing]
	@HeaderID int	
AS

SET NOCOUNT ON;

-- set database state to PROCESSING
UPDATE dbo.[Config] SET [DatabaseState] = 1;

UPDATE [dbo].[Transaction]
SET [TransactionStatus] = 1
	, [BeginTime] = GETDATE()
WHERE HeaderID = @HeaderID;


GO


