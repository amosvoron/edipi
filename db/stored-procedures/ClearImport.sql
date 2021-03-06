USE [EDIPI]
GO
/****** Object:  StoredProcedure [dbo].[ClearImport]    Script Date: 4. 03. 2020 21:41:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:				dbo.ClearImport
Description:		Clears dbo.Import table and prepare its RowID identifier for next import.
*/

ALTER PROCEDURE [dbo].[ClearImport]
AS

SET NOCOUNT ON;

-- clear
TRUNCATE TABLE dbo.Import;

-- set seed
DECLARE @LastRowID AS bigint;
SET @LastRowID = ISNULL((SELECT MAX(LastRowID) + 1 FROM dbo.[File]), 1);
DBCC CHECKIDENT ('dbo.Import', reseed, @LastRowID);

EXEC dbo.FastPrint '-----------------------------------------------';
EXEC dbo.FastPrint 'Import table has been cleared and reseeded.';

DECLARE @msg AS nvarchar(100) = 'Next RowID set to: ' + CAST(@LastRowID AS nvarchar(20));
EXEC dbo.FastPrint @msg;
EXEC dbo.FastPrint '-----------------------------------------------';

