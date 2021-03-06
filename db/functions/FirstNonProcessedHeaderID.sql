
/*
Object:				dbo.FirstNonProcessedHeaderID
Description:		Returns the first non-processed transaction (HeaderID).
*/

CREATE FUNCTION [dbo].[FirstNonProcessedHeaderID]()
RETURNS bigint
AS
BEGIN
    RETURN (
		SELECT TOP(1) [HeaderID]
		FROM [dbo].[Transaction]
		WHERE [TransactionStatus] < 2
		ORDER BY HeaderID ASC);
END;
