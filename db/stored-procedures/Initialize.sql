
/*
Object:			dbo.Initialize
Description:	Puts the database into PROCESSING state, clears the dbo.Import table, and reseeds RowID.
Note:			This procedure is called AT THE BEGINNING of the dbo.ProcessDiff processing.
*/

CREATE PROCEDURE [dbo].[Initialize]
AS

SET NOCOUNT ON;

EXEC dbo.FastPrint '=============================================================';
EXEC dbo.FastPrint 'THE PROCESSING STARTED. DATABASE IS IN PROCESSING STATE.';
EXEC dbo.FastPrint '=============================================================';

-- set database state to PROCESSING
UPDATE dbo.[Config] SET [DatabaseState] = 1;

-- clear & reseed import table
EXEC [dbo].[ClearImport];

-- disable reject triggers and enable revision triggers
EXEC dbo.DisableRejectTriggers;


GO


