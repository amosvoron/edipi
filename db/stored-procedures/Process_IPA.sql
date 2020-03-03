
/*
Object:			dbo.Process_IPA
Description:	Process all IPA records from the initial TOTAL IMPORT into [ipi] schema.

Important:		HeaderID is the replacement for TranSeq as it is unique transaction identifier in the 
				entire dbo.Row table while the TranSeq is only unique in a single transaction file.

	IPA:IPA
	IPA:BDN
	IPA:STN
	IPA:NCN,ONN,MCN
	IPA:MAN
	IPA:TMA
	IPA:NTN
	IPA:NUN,INN
	IPA:MUN,IMN

*/

CREATE PROCEDURE [dbo].[Process_IPA]
AS

SET NOCOUNT ON;

BEGIN TRY

------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '10> IPA:IPA';
	INSERT INTO ipi.IP
	(RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex)
	SELECT RowID, IPBN, [Type], BirthDate, DeathDate, BirthPlace, BirthState, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator, Sex
	FROM dbo.[Row]
	WHERE 
		RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND HeaderCode = 'IPA'
		AND RowCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '20> IPA:BDN';
	WITH _BDN AS
	(
		SELECT
			A.RowID, B.Sex, B.[Type], B.BirthDate, B.DeathDate, B.BirthPlace, B.BirthState
			, B.TISN, B.TISNValidFrom, B.TISAN, B.TISANValidFrom, B.IEIndicator
			, B.AmendDate, B.AmendTime
		FROM dbo.[Row] AS A
		INNER JOIN dbo.[Row] AS B 
			ON A.RowID + 1 = B.RowID
		WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
			AND A.HeaderCode = 'IPA'
			AND B.RowCode = 'BDN'
	)
	UPDATE X
	SET 
		X.Sex = A.Sex
		, X.[Type] = A.[Type]
		, X.BirthDate = A.BirthDate
		, X.DeathDate = A.DeathDate
		, X.BirthPlace = A.BirthPlace
		, X.BirthState = A.BirthState
		, X.TISN = A.TISN
		, X.TISNValidFrom = A.TISNValidFrom
		, X.TISAN = A.TISAN
		, X.TISANValidFrom = A.TISANValidFrom
		, X.IEIndicator = A.IEIndicator
		, X.AmendDate = A.AmendDate
		, X.AmendTime = A.AmendTime
	FROM ipi.IP AS X
	INNER JOIN _BDN AS A
		ON X.RowID = A.RowID;
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '30> IPA:STN';
	INSERT INTO ipi.IPStatus
	(RowID, ID, RefID, StatusCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime, AmendDate, AmendTime)
	SELECT 
		A.RowID
		, R1.ID
		, R2.ID
		, A.StatusCode
		, A.ValidFromDate
		, A.ValidFromTime
		, A.ValidToDate
		, A.ValidToTime
		, A.AmendDate
		, A.AmendTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R1
		ON H.IPBN = R1.IPBN

	-- IP reference of a status row	(different than ID if status is 2 or 3)
	INNER JOIN ipi.IP AS R2
		ON A.IPBNRef = R2.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode = 'STN'
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '40> IPA:NCN,ONN,MCN';
	INSERT INTO ipi.IPName
	(RowID, ID, IPNN, NameType, Name, FirstName, AmendDate, AmendTime, CreationDate, CreationTime)
	SELECT A.RowID, R.ID, A.IPNN, A.NameType, A.Name, A.FirstName, A.AmendDate, A.AmendTime, A.CreationDate, A.CreationTime

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('NCN','ONN','MCN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '50> IPA:MAN';
	EXEC dbo.Query_50_Init;

	-- The script below is intolerably slow! Consuming very large amount of too disk space (over 50GB for transaction log only).
	-- And it failed 3-times due to full transaction log (after processing in total over 24 hours.)
	-------------------------------------------------------------------------------------------------
	-- DO NOT RUN THIS SCRIPT UNLESS YOU HAVE 100GB DISK SPACE AND A ROCKET ENGINE.
	-------------------------------------------------------------------------------------------------
	/*
		EXEC dbo.FastPrint '50> IPA:MAN';
		INSERT INTO ipi.IPMembership
		(RowID, ID, NID, SocietyCode, SocietyName, CCCode, RoleCode, RightCode, ValidFromDate, ValidFromTime, ValidToDate, ValidToTime
			, SignDate, MemberShare, AmendDate, AmendTime)

		SELECT A.RowID, R.ID, N.NID, A.SocietyCode, A.SocietyName, A.CCCode, A.RoleCode, A.RightCode, A.ValidFromDate, A.ValidFromTime, A.ValidToDate, A.ValidToTime
			, A.SignDate, A.MemberShare, A.AmendDate, A.AmendTime

		-- data rows
		FROM dbo.[Row] AS A

		-- tran header row
		INNER JOIN dbo.[Row] AS H 
			ON H.RowCode = 'IPA'
				AND H.HeaderID = A.HeaderID		-- the same tran group

		INNER JOIN ipi.IP AS R
			ON H.IPBN = R.IPBN
		INNER JOIN ipi.IPName AS N 
			ON R.ID = N.ID
				AND H.IPNN = N.IPNN

		WHERE A.RowCode = 'MAN'
			AND A.HeaderCode = 'IPA'
			AND A.RowID <= 273810673;		-- DO NOT USE A VARIABLE (due to Query Tuning)
	*/
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '60> IPA:TMA';
	EXEC dbo.Query_60_Init;

	-------------------------------------------------------------------------------------------------
	-- THIS SCRIPT IS ALSO VERY SLOW. DO NOT RUN IT.
	-------------------------------------------------------------------------------------------------
	/*
		EXEC dbo.FastPrint '60> IPA:TMA';
		INSERT INTO ipi.IPMembershipTerritory
		(RowID, MID, TISN, TISNValidFrom, TISAN, TISANValidFrom, IEIndicator)
		SELECT X.RowID, A.MID, X.TISN, X.TISNValidFrom, X.TISAN, X.TISANValidFrom, X.IEIndicator
		FROM dbo.[Row] AS X

		-- find parent
		CROSS APPLY (
			SELECT TOP(1) AA.RowID, AA.MID
			FROM ipi.IPMembership AS AA
			INNER JOIN dbo.[Row] AS BB ON AA.RowID = BB.RowID
			WHERE AA.RowID < X.RowID
				AND BB.HeaderID = X.HeaderID	-- the same tran group
			ORDER BY AA.RowID DESC
		) AS A

		WHERE X.RowCode = 'TMA' 
			AND X.HeaderCode = 'IPA'
			AND X.RowID <= 273810673;		-- DO NOT USE A VARIABLE (due to Query Tuning)
	*/
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '70> IPA:NTN';
	INSERT INTO ipi.IPNationality
	(RowID, ID, TISN, TISNValidFrom, TISAN, TISANValidFrom, ValidFrom, ValidTo)
	SELECT 
		A.RowID
		, R.ID
		, A.TISN
		, A.TISNValidFrom
		, A.TISAN
		, A.TISANValidFrom
		, A.ValidFromDate
		, A.ValidToDate

	-- data rows
	FROM dbo.[Row] AS A

	-- header row
	INNER JOIN dbo.[Row] AS H 
		ON H.RowCode = 'IPA'
			AND H.HeaderID = A.HeaderID		-- the same tran group

	-- IP of a status row
	INNER JOIN ipi.IP AS R
		ON H.IPBN = R.IPBN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode = 'NTN'
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '80> IPA:NUN,INN';
	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode

	FROM dbo.[Row] AS A
	INNER JOIN ipi.IPName AS R
		ON A.IPNN = R.IPNN

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('NUN','INN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------
	EXEC dbo.FastPrint '90> IPA:MUN,IMN';
	INSERT INTO ipi.IPNameUsage
	(RowID, NID, CCCode, RoleCode)
	SELECT 
		A.RowID
		, R.NID
		, A.CCCode
		, A.RoleCode
	FROM dbo.[Row] AS A
	INNER JOIN ipi.IP AS S ON A.IPBN = S.IPBN
	INNER JOIN ipi.IPName AS R ON A.IPNN = R.IPNN
		AND S.ID = R.ID

	WHERE A.RowID <= 273810673		-- DO NOT USE A VARIABLE (due to Query Tuning)
		AND A.RowCode IN ('MUN','IMN')
		AND A.HeaderCode = 'IPA';
------------------------------------------------------------------------------------------------------------------

END TRY
BEGIN CATCH

	EXEC dbo.FastPrint '-----------------------------------------------------';
	EXEC dbo.FastPrint 'IPA transactions have failed.';	
	DECLARE @e nvarchar(MAX),@v int,@s int; SELECT @e = ERROR_MESSAGE(),@v = ERROR_SEVERITY(),@s = ERROR_STATE(); 
	RAISERROR(@e, @v, @s);
	
END CATCH;


GO


