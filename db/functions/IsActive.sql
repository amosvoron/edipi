
/*
Object:				dbo.IsActive
Description:		Returns 1 if the transaction is active.
					Non-existing transaction is considered as inactive.
*/

CREATE FUNCTION [dbo].[IsActive](@HeaderID bigint)
RETURNS bigint
AS
BEGIN
    RETURN ISNULL((
		SELECT 
			CASE WHEN TransactionStatus = 2 THEN 0
			ELSE 1 END AS IsActive
		FROM [dbo].[Transaction]
		WHERE HeaderID = @HeaderID
	), 0);
END;
GO

