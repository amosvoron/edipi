
/*
Object:			dbo.SetTranAsFailed
Description:	Sets the transaction as failed.
Note:			This procedure is called after the transaction has FAILED and is ROLLED BACK. 
*/

CREATE PROCEDURE [dbo].[SetTranAsFailed]
	@HeaderID int	
AS

SET NOCOUNT ON;

UPDATE [dbo].[Transaction]
SET [TransactionStatus] = -1
WHERE HeaderID = @HeaderID;


GO


