
/*
Object:			dbo.SetTranAsCommited
Description:	Sets the transaction as commited.
Note:			This procedure is called after the transaction has been SUCCESSFULLY commited. 
*/

CREATE PROCEDURE [dbo].[SetTranAsCommited]
	@HeaderID int	
AS

SET NOCOUNT ON;

-- transaction table
UPDATE [dbo].[Transaction]
SET [TransactionStatus] = 2
	, [EndTime] = GETDATE()
WHERE HeaderID = @HeaderID;

-- database configuration table
UPDATE dbo.Config
SET [LastCommitedHeaderID] = @HeaderID;


GO


