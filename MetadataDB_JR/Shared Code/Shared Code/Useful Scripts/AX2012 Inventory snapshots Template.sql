
--======================================--
-- Object Creation TEMPLATE			--
-- Press Ctrl-Shift-M to enter variables--
--======================================--

DECLARE @TemplateValue AS VARCHAR(200) = '<AX_Database_Name, VARCHAR(100), >'

IF @TemplateValue LIKE '<%'
BEGIN
    THROW 50001, 'The template has not been populated. Hold Ctrl-Shift-M and fill in the database name. Then Re-run the script', 1;
    set noexec on
END 
GO


USE <AX_Database_Name, VARCHAR(100), >
GO

/****** Object:  Schema [dw]    Script Date: 4/07/2014 12:29:02 PM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dw')
EXEC sys.sp_executesql N'CREATE SCHEMA [dw]'

GO

/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventory]    Script Date: 4/07/2014 12:29:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dw].[InsSnapshot_WarehouseInventory]
GO

/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventory]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dw].[InsSnapshot_WarehouseInventory] @cpnyid VARCHAR(10)
AS
BEGIN
	--Set up error variables for reporting   
	DECLARE @ErrorCode INT
		,@ErrorMessage NVARCHAR(MAX)
		,@ErrorSeverity INT
		,@ErrorState INT

	-- SET NOCOUNT ON added to prevent extra result sets from  
	-- interfering with SELECT statements.  
	SET NOCOUNT ON;

	BEGIN TRY
		-- Testing
		-- DROP TABLE #Currency
		-- DECLARE @cpnyid VARCHAR(10) = ''TUR1''

		-- Get Partition for company
		DECLARE @partitionid bigint
		SELECT @partitionid = [PARTITION] 
		FROM  [dbo].[DATAAREA]
		WHERE id = @cpnyid


		SELECT DATAAREA.ID
			,DATAAREA.NAME
			,LEDGER.ACCOUNTINGCURRENCY AS CURRENCYCODE
		INTO #Currency
		FROM DATAAREA DATAAREA WITH (NOLOCK)
		INNER JOIN LEDGER LEDGER WITH (NOLOCK)
			ON DATAAREA.ID = LEDGER.NAME

		DECLARE @WarehouseInventoryDate AS DATETIME
		DECLARE @CurrencyEffectiveDate AS DATETIME

		SELECT @WarehouseInventoryDate = (
				SELECT CAST(CONVERT(VARCHAR(8), DATEADD(day, - 1, (DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE()))), 112) AS DATETIME) -- UTC to local company time
				FROM DW.SnapshotCompany
				WHERE CompanyCode = @cpnyid
				)

		SELECT @CurrencyEffectiveDate = (
				SELECT CAST(CONVERT(VARCHAR(8), DATEADD(day, - 1, (DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE()))), 112) AS DATETIME) -- UTC to local company time
				FROM DW.SnapshotCompany
				WHERE CompanyCode = @cpnyid
				)

		--*********INSERT INTO SNAPSHOT TABLE HERE**************--
		INSERT INTO dw.WarehouseInventory_SnapShot (
			WarehouseInventoryDate
			,DataAreaID
			,InventLocationID
			,ItemID
			,CurrencyCode
			,CurrencyEffectiveDate
			,Price
			,PostedQty
			,Received
			,Deducted
			,Registered
			,Picked
			,PhysicalValue
			,PostedValue
			)
		SELECT @WarehouseInventoryDate AS WarehouseInventoryDate
			,UPPER(INVENTSUM.DATAAREAID)
			,INVENTDIM.INVENTLOCATIONID
			,INVENTSUM.ITEMID
			,cc.CURRENCYCODE
			,@CurrencyEffectiveDate AS CurrencyEffectiveDate
			,CASE	WHEN sum(INVENTSUM.PostedQty + (INVENTSUM.Received - INVENTSUM.Deducted)) > 0
					THEN SUM(INVENTSUM.PHYSICALVALUE + INVENTSUM.POSTEDVALUE) / 
					(	
					CASE 
					WHEN sum(INVENTSUM.POSTEDQTY + (INVENTSUM.RECEIVED - INVENTSUM.DEDUCTED)) <> 0
					THEN sum(INVENTSUM.POSTEDQTY + (INVENTSUM.RECEIVED - INVENTSUM.DEDUCTED))
					ELSE 1
					END
					)
			ELSE 0
			END AS Price
			,SUM(INVENTSUM.PostedQty) AS PostedQty
			,SUM(INVENTSUM.Received) AS Received
			,SUM(INVENTSUM.Deducted) AS Deducted
			,SUM(INVENTSUM.Registered) AS Registered
			,SUM(INVENTSUM.Picked) AS Picked
			,SUM(INVENTSUM.PHYSICALVALUE) AS PhysicalValue
			,SUM(INVENTSUM.POSTEDVALUE) AS PostedValue
		FROM INVENTSUM INVENTSUM WITH (NOLOCK)
		INNER JOIN INVENTDIM INVENTDIM WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTDIM.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTDIM.DATAAREAID
				AND INVENTSUM.INVENTDIMID = INVENTDIM.INVENTDIMID
		INNER JOIN INVENTLOCATION INVENTLOCATION WITH (NOLOCK)
			ON INVENTDIM.[PARTITION] = INVENTLOCATION.[PARTITION]
				AND INVENTDIM.DATAAREAID = INVENTLOCATION.DATAAREAID
				AND INVENTDIM.INVENTLOCATIONID = INVENTLOCATION.INVENTLOCATIONID
		INNER JOIN WMSLOCATION WMSLOCATION WITH (NOLOCK)
			ON INVENTDIM.PARTITION = WMSLOCATION.PARTITION
				AND INVENTDIM.DATAAREAID = WMSLOCATION.DATAAREAID
				AND INVENTDIM.WMSLOCATIONID = WMSLOCATION.WMSLOCATIONID
				AND INVENTDIM.INVENTLOCATIONID = WMSLOCATION.INVENTLOCATIONID
		INNER JOIN INVENTTABLEMODULE INVENTTABLEMODULE WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTTABLEMODULE.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTTABLEMODULE.DATAAREAID
				AND INVENTSUM.ITEMID = INVENTTABLEMODULE.ITEMID
				AND INVENTTABLEMODULE.MODULETYPE = 0 -- Inventory
		LEFT JOIN #Currency cc
			ON cc.ID = INVENTSUM.DATAAREAID
		WHERE INVENTSUM.[PARTITION] = @partitionid 
			AND LTRIM(RTRIM(INVENTSUM.DATAAREAID)) = @cpnyid
		GROUP BY INVENTSUM.DATAAREAID
			,INVENTSUM.ITEMID
			,INVENTDIM.INVENTLOCATIONID
			,cc.CURRENCYCODE
			--End Extract Logic						

	END TRY

	--Trap Errors  
	-------------- 
	BEGIN CATCH
		SELECT @ErrorMessage = Error_message()
			,@ErrorSeverity = Error_severity()
			,@ErrorState = Error_state()
			,@ErrorCode = Error_number()

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ErrorState
				)
	END CATCH
		--Finally Section 
END

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dw].[InsSnapshot_WarehouseInventoryAgeing]'') AND type in (N''P'', N''PC''))
BEGIN
DECLARE @SQL NVARCHAR(4000)
SET @SQL = ''CREATE PROCEDURE [dw].[InsSnapshot_WarehouseInventoryAgeing]
AS BEGIN 
SET NOCOUNT ON
END''
EXEC sp_executesql @SQL
END

' 
END
GO

/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventoryAgeing]    Script Date: 4/07/2014 12:29:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventoryAgeing]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dw].[InsSnapshot_WarehouseInventoryAgeing]
GO


/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventoryAgeing]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventoryAgeing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dw].[InsSnapshot_WarehouseInventoryAgeing] @cpnyid VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
		
	DECLARE @itemid nVARCHAR(30)
	DECLARE @qtyonhand DECIMAL(10, 0)
	DECLARE @Location NVARCHAR(10)
	DECLARE @cost DECIMAL(18, 6)
	DECLARE @RowCnt INT
	DECLARE @MaxRows INT
	DECLARE @currencycode nVARCHAR(6)
	DECLARE @trandate DATETIME


	SELECT @trandate = DATEADD(day, 0, (DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE()))) 
	FROM DW.SnapshotCompany
	WHERE CompanyCode = @cpnyid

    -- Get Partition for company
    DECLARE @partitionid bigint
    SELECT @partitionid = [PARTITION] 
    FROM  [dbo].[DATAAREA]
    WHERE id = @cpnyid


	DECLARE @aging TABLE (
		itemid VARCHAR(30)
		,INVENTLOCATIONID NVARCHAR(10)
		,qtyonhand DECIMAL(10, 0)
		,cost DECIMAL(18, 6)
		,rownum INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
		)
	DECLARE @total TABLE (
		itemid VARCHAR(30)
		,INVENTLOCATIONID NVARCHAR(10)
		,total1 NUMERIC(28, 12)
		,total2 NUMERIC(28, 12)
		)
	DECLARE @sbsantigdet TABLE (
		CPNYID VARCHAR(10)
		,invtid CHAR(24)
		,Location NVARCHAR(10)
		,qty FLOAT
		,cost FLOAT
		,bucket01 FLOAT
		,bucket02 FLOAT
		,bucket03 FLOAT
		,bucket04 FLOAT
		,bucket05 FLOAT
		,bucket06 FLOAT
		,bucket07 FLOAT
		,bucket08 FLOAT	
		)
	DECLARE @invtaging TABLE (
		CPNYID VARCHAR(10)
		,invtid CHAR(24)
		,Location NVARCHAR(40)
		,qty FLOAT
		,cost FLOAT
		,currencycode VARCHAR(6)
		,ageingid VARCHAR(2)
		)
	DECLARE @stock TABLE (
		itemid VARCHAR(30)
		,INVENTLOCATIONID NVARCHAR(10)
		,qty INT
		,cost NUMERIC(17, 6)
		)	
	DECLARE @settled TABLE (
		itemid VARCHAR(30)
		,transrecid BIGINT
		,CostAmountSettled NUMERIC(28, 12)
		,qtysettled NUMERIC(28, 12)
		,costamountadjustment NUMERIC(28, 12)
		)
	DECLARE @CostTable TABLE (
		itemid VARCHAR(30)
		,INVENTLOCATIONID NVARCHAR(40)
		,Cost NUMERIC(28, 12)
		)	
	

	/*************************************************************************************************************
	Get cost
	*************************************************************************************************************/
	INSERT INTO @CostTable
	SELECT 	INVENTSUM.ITEMID
			,INVENTDIM.INVENTLOCATIONID
			,CASE	WHEN sum(INVENTSUM.PostedQty + (INVENTSUM.Received - INVENTSUM.Deducted)) > 0
					THEN SUM(INVENTSUM.PHYSICALVALUE + INVENTSUM.POSTEDVALUE) / 
					(	
					CASE 
					WHEN sum(INVENTSUM.POSTEDQTY + (INVENTSUM.RECEIVED - INVENTSUM.DEDUCTED)) <> 0
					THEN sum(INVENTSUM.POSTEDQTY + (INVENTSUM.RECEIVED - INVENTSUM.DEDUCTED))
					ELSE 1
					END
					)
			ELSE 0
			END AS Cost
		FROM INVENTSUM INVENTSUM WITH (NOLOCK)
		INNER JOIN INVENTDIM INVENTDIM WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTDIM.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTDIM.DATAAREAID
				AND INVENTSUM.INVENTDIMID = INVENTDIM.INVENTDIMID
		INNER JOIN INVENTLOCATION INVENTLOCATION WITH (NOLOCK)
			ON INVENTDIM.[PARTITION] = INVENTLOCATION.[PARTITION]
				AND INVENTDIM.DATAAREAID = INVENTLOCATION.DATAAREAID
				AND INVENTDIM.INVENTLOCATIONID = INVENTLOCATION.INVENTLOCATIONID
		INNER JOIN WMSLOCATION WMSLOCATION WITH (NOLOCK)
			ON INVENTDIM.PARTITION = WMSLOCATION.PARTITION
				AND INVENTDIM.DATAAREAID = WMSLOCATION.DATAAREAID
				AND INVENTDIM.WMSLOCATIONID = WMSLOCATION.WMSLOCATIONID
				AND INVENTDIM.INVENTLOCATIONID = WMSLOCATION.INVENTLOCATIONID
		INNER JOIN INVENTTABLEMODULE INVENTTABLEMODULE WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTTABLEMODULE.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTTABLEMODULE.DATAAREAID
				AND INVENTSUM.ITEMID = INVENTTABLEMODULE.ITEMID
				AND INVENTTABLEMODULE.MODULETYPE = 0 -- Inventory
		WHERE INVENTSUM.[PARTITION] = @partitionid 
			AND LTRIM(RTRIM(INVENTSUM.DATAAREAID)) = @cpnyid
		GROUP BY INVENTSUM.ITEMID
				,INVENTDIM.INVENTLOCATIONID


	/*************************************************************************************************************
	Get Quantity on hand 
	*************************************************************************************************************/

	INSERT INTO @total
	SELECT inventSum.[ITEMID]
		,INVENTDIM.INVENTLOCATIONID
		,(sum(inventSum.PostedQty) + sum(inventSum.Received) - sum(inventSum.Deducted)) + SUM(inventSum.Registered)  AS total1
		,0 AS total2
	FROM INVENTSUM INVENTSUM WITH (NOLOCK)
		INNER JOIN INVENTDIM INVENTDIM WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTDIM.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTDIM.DATAAREAID
				AND INVENTSUM.INVENTDIMID = INVENTDIM.INVENTDIMID
		INNER JOIN INVENTLOCATION INVENTLOCATION WITH (NOLOCK)
			ON INVENTDIM.[PARTITION] = INVENTLOCATION.[PARTITION]
				AND INVENTDIM.DATAAREAID = INVENTLOCATION.DATAAREAID
				AND INVENTDIM.INVENTLOCATIONID = INVENTLOCATION.INVENTLOCATIONID
		INNER JOIN WMSLOCATION WMSLOCATION WITH (NOLOCK)
			ON INVENTDIM.PARTITION = WMSLOCATION.PARTITION
				AND INVENTDIM.DATAAREAID = WMSLOCATION.DATAAREAID
				AND INVENTDIM.WMSLOCATIONID = WMSLOCATION.WMSLOCATIONID
				AND INVENTDIM.INVENTLOCATIONID = WMSLOCATION.INVENTLOCATIONID
		INNER JOIN INVENTTABLEMODULE INVENTTABLEMODULE WITH (NOLOCK)
			ON INVENTSUM.[PARTITION] = INVENTTABLEMODULE.[PARTITION]
				AND INVENTSUM.DATAAREAID = INVENTTABLEMODULE.DATAAREAID
				AND INVENTSUM.ITEMID = INVENTTABLEMODULE.ITEMID
				AND INVENTTABLEMODULE.MODULETYPE = 0 -- Inventory	
		WHERE INVENTSUM.[PARTITION] = @partitionid 
			AND LTRIM(RTRIM(INVENTSUM.DATAAREAID)) = @cpnyid
			AND inventSum.Closed = 0
		GROUP BY INVENTSUM.ITEMID
				,INVENTDIM.INVENTLOCATIONID



	INSERT INTO @stock
	SELECT INVENTTABLE.ITEMID
		,Total.INVENTLOCATIONID
		,coalesce(sum(total1), 0) + coalesce(sum(total2), 0) AS QTY
		,0
	FROM INVENTTABLE INVENTTABLE WITH (NOLOCK)
	INNER JOIN @total Total
		ON Total.itemid = INVENTTABLE.ITEMID
	WHERE INVENTTABLE.[PARTITION] = @partitionid
		AND INVENTTABLE.DATAAREAID = @cpnyid
		AND INVENTTABLE.itemtype <> 2 -- item or part of BOM, not a service
	GROUP BY INVENTTABLE.ITEMID
		,Total.INVENTLOCATIONID

	INSERT INTO @aging
	SELECT Stock.ItemId
		,Stock.INVENTLOCATIONID
		,SUM(Stock.QTY) AS QTYONHAND
		,CostTable.Cost AS Cost
	FROM @stock Stock	
	JOIN @CostTable AS CostTable
		ON Stock.itemid = CostTable.itemid
		AND Stock.INVENTLOCATIONID = CostTable.INVENTLOCATIONID
	GROUP BY stock.ITEMID
		,Stock.INVENTLOCATIONID
		,CostTable.Cost
	
	-- get aging
	SELECT @RowCnt = 1

	-- Initialize Count Variable for the Cursor
	SELECT @MaxRows = count(*)
	FROM @aging

	-- Start Cursor Loop  
	WHILE @RowCnt <= @MaxRows
	BEGIN
		SELECT @itemid = itemid
			,@Location = INVENTLOCATIONID
			,@qtyonhand = qtyonhand
			,@cost = cost
		FROM @aging
		WHERE rownum = @rowcnt

		INSERT INTO @sbsantigdet
		SELECT @cpnyid
			,@itemid
			,@Location
			,@qtyonhand
			,@cost
			,x.bucket01
			,x.bucket02
			,x.bucket03
			,x.bucket04
			,x.bucket05
			,x.bucket06
			,x.bucket07
			,x.bucket08
		FROM dw.fn_gettranbucket(@cpnyid, @itemid, @Location, @qtyonhand, @trandate) AS x

		SET @RowCnt = @RowCnt + 1
	END

	SELECT @currencycode = AccountingCurrency
	FROM LEDGER(NOLOCK)
	WHERE ledger.NAME = @cpnyid

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket01
		,COST
		,@currencycode
		,''01''
	FROM @sbsantigdet
	WHERE bucket01 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket02
		,COST
		,@currencycode
		,''02''
	FROM @sbsantigdet
	WHERE bucket02 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket03
		,COST
		,@currencycode
		,''03''
	FROM @sbsantigdet
	WHERE bucket03 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket04
		,COST
		,@currencycode
		,''04''
	FROM @sbsantigdet
	WHERE bucket04 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket05
		,COST
		,@currencycode
		,''05''
	FROM @sbsantigdet
	WHERE bucket05 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket06
		,COST
		,@currencycode
		,''06''
	FROM @sbsantigdet
	WHERE bucket06 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket07
		,COST
		,@currencycode
		,''07''
	FROM @sbsantigdet
	WHERE bucket07 > 0

	INSERT INTO @invtaging
	SELECT cpnyid
		,invtid
		,Location
		,bucket08
		,COST
		,@currencycode
		,''08''
	FROM @sbsantigdet
	WHERE bucket08 > 0

	BEGIN
		INSERT INTO dw.WarehouseInventoryAgeing_SnapShot (
			WarehouseInventoryDate
			,CpnyID
			,InvtId
			,SiteID
			,AgeingId
			,CurrencyCode
			,CurrencyEffectiveDate
			,Qty
			,Cost
			)
		SELECT CAST(CONVERT(VARCHAR(8), DATEADD(day, - 1, (DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE()))), 112) AS DATETIME) AS WarehouseInventoryDate
			,CpnyID
			,InvtId
			,Location AS SiteID
			,AgeingId
			,CurrencyCode
			,CAST(CONVERT(VARCHAR(8), DATEADD(day, - 1, (DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE()))), 112) AS DATETIME) AS CurrencyEffectiveDate
			,Qty
			,Cost
		FROM @invtaging inv
		INNER JOIN DW.SnapshotCompany sc
			ON inv.CPNYID = sc.CompanyCode
	END
END





SET ANSI_NULLS ON

' 
END
GO

/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventoryMaster]    Script Date: 4/07/2014 12:29:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventoryMaster]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dw].[InsSnapshot_WarehouseInventoryMaster]
GO


/****** Object:  StoredProcedure [dw].[InsSnapshot_WarehouseInventoryMaster]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[InsSnapshot_WarehouseInventoryMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [dw].[InsSnapshot_WarehouseInventoryMaster]
AS
BEGIN
	--Set up error variables for reporting   
	DECLARE @ErrorCode INT
		,@ErrorMessage NVARCHAR(MAX)
		,@ErrorSeverity INT
		,@ErrorState INT

	-- SET NOCOUNT ON added to prevent extra result sets from  
	-- interfering with SELECT statements.  
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	BEGIN TRY
		DECLARE @Id INT
		DECLARE @CC NVARCHAR(255)
		DECLARE @sql NVARCHAR(255)
		DECLARE @Table TABLE (
			ID INT IDENTITY(1, 1)
			,CompanyCode NVARCHAR(40) NOT NULL
			,TimeDif DECIMAL NOT NULL
			);

		-- Need to get the list of companies that need the extract run, date from their timezone and 2am in their timezone that have not already been extracted
		-- Get all companies and all last runtimeUTC and TimeDiff, then get the date out of the RunTime using the time diff
		-- Get list of companies where a snapshot is needed
		INSERT INTO @Table
		SELECT CompanyCode
			,CAST(TimeDif AS DECIMAL) TimeDif
		FROM DW.SnapshotCompany
		WHERE NextExtractTimeCompany <= DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE())
			AND GETUTCDATE() > DATEADD(HOUR, CAST(TimeDif AS DECIMAL), LastExtractTimeCompany)
			AND Process = 1
			AND ISNULL(Deleted, 0) <> 1

		SELECT @Id = (
				SELECT COUNT(Id)
				FROM @Table
				)

		WHILE @Id > 0
		BEGIN
			SELECT @CC = CompanyCode
			FROM @Table
			WHERE Id = @Id

			SELECT @SQL = ''[DW].[InsSnapshot_WarehouseInventory] '' + @CC
			EXEC (@sql)

			SELECT @SQL = ''[DW].[InsSnapshot_WarehouseInventoryAgeing] '' + @CC
			EXEC (@sql)

			DELETE @Table
			WHERE Id = @Id

			SELECT @Id = (
					SELECT COUNT(Id)
					FROM @Table
					)

			UPDATE DW.SnapshotCompany
			SET LastExtractTimeUTC = GETUTCDATE()
				,NextExtractTimeUTC = DATEADD(hh, CAST(TimeDif AS DECIMAL), DATEDIFF(dd, 0, DATEADD(dd, 1, GetUTCDate())))
				,LastExtractTimeCompany = DATEADD(HOUR, CAST(TimeDif AS DECIMAL), GETUTCDATE())
				,NextExtractTimeCompany = DATEADD(hh, 02, DATEDIFF(dd, 0, DATEADD(dd, 1, GetDate())))
			WHERE CompanyCode = @CC
		END
				--End Extract Logic
	END TRY

	--Trap Errors  
	-------------- 
	BEGIN CATCH
		SELECT @ErrorMessage = Error_message()
			,@ErrorSeverity = Error_severity()
			,@ErrorState = Error_state()
			,@ErrorCode = Error_number()

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ErrorState
				)
	END CATCH
		--Finally Section 
END



' 
END
GO

/****** Object:  StoredProcedure [dw].[LoadSnapshotCompany]    Script Date: 4/07/2014 12:29:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[LoadSnapshotCompany]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dw].[LoadSnapshotCompany]
GO


/****** Object:  StoredProcedure [dw].[LoadSnapshotCompany]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[LoadSnapshotCompany]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- ====================================================================================

-- Author:		Dylan Harvey
-- Description:	Gets a list of all the companies in the ERP and the business time of each company in relation to UTC
--
-- ====================================================================================
CREATE PROCEDURE [dw].[LoadSnapshotCompany]


AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	BEGIN TRY

		/* drop the temporary table if exists */
		IF OBJECT_ID(''tempdb..#SnapShotTable'') IS NOT NULL
			DROP TABLE #SnapShotTable


		/* select the rows based on ExtractJobID into temporary table */
		SELECT [ID] AS CompanyCode  
		, [TIMEZONEKEYNAME]
		, CASE
			WHEN SUBSTRING([ENUMNAME],4,1) =  ''_'' THEN ''0''
			WHEN SUBSTRING([ENUMNAME],4,1) =  ''P'' THEN ''+'' + SUBSTRING([ENUMNAME],8,2) + CASE WHEN SUBSTRING([ENUMNAME],10,2) <> ''00'' THEN ''.5'' ELSE '''' END
			WHEN SUBSTRING([ENUMNAME],4,1) =  ''M'' THEN ''-'' + SUBSTRING([ENUMNAME],9,2) + CASE WHEN SUBSTRING([ENUMNAME],11,2) <> ''00'' THEN ''.5'' ELSE '''' END
			END AS ''TimeDif''
		, ''1900-01-01'' AS LastExtractTimeUTC
		, ''1900-01-01'' AS NextExtractTimeUTC
		, ''1900-01-01'' AS LastExtractTimeCompany
		, ''1900-01-01'' AS NextExtractTimeCompany
		, 1 AS Process
		, Null as Deleted
		INTO #SnapShotTable
		FROM [dbo].[DATAAREA] CompanyTable WITH (NOLOCK)
		JOIN  [dbo].[TIMEZONESLIST] TimeZone WITH (NOLOCK)
			ON TimeZone.[TZENUM] = CompanyTable.[TIMEZONE]

		/* merge the records (insert new rows and update existing rows) */
		MERGE [dw].[SnapshotCompany] AS target
		USING 
		(
		SELECT 
			CompanyCode,
			TIMEZONEKEYNAME,
			TimeDif,
			LastExtractTimeUTC,
			NextExtractTimeUTC,
			LastExtractTimeCompany,
			NextExtractTimeCompany,
			Process,
			Deleted
		FROM #SnapShotTable
		) AS source 
		(
			CompanyCode,
			TIMEZONEKEYNAME,
			TimeDif,
			LastExtractTimeUTC,
			NextExtractTimeUTC,
			LastExtractTimeCompany,
			NextExtractTimeCompany,
			Process,
			Deleted
		)

		ON 
		(
			(target.CompanyCode = source.CompanyCode)
		)
		WHEN NOT MATCHED THEN 
		INSERT (
			CompanyCode,
			TIMEZONEKEYNAME,
			TimeDif,
			LastExtractTimeUTC,
			NextExtractTimeUTC,
			LastExtractTimeCompany,
			NextExtractTimeCompany,
			Process,
			Deleted
		)
		VALUES
		(
			Source.CompanyCode,
			Source.TIMEZONEKEYNAME,
			Source.TimeDif,
			Source.LastExtractTimeUTC,
			Source.NextExtractTimeUTC,
			Source.LastExtractTimeCompany,
			Source.NextExtractTimeCompany,
			Source.Process,
			Source.Deleted
		)
		WHEN MATCHED AND 
			--compare excluding business key
			(	
				HASHBYTES(''MD5'',
					COALESCE(RTRIM(CAST(target.TIMEZONEKEYNAME AS nvarchar(100))),'''')
					+ COALESCE(RTRIM(CAST(target.TimeDif AS nvarchar(100))),'''')						
				)
				<>
				HASHBYTES(''MD5'',
					COALESCE(RTRIM(CAST(source.TIMEZONEKEYNAME AS nvarchar(100))),'''')
					+ COALESCE(RTRIM(CAST(source.TimeDif AS nvarchar(100))),'''')
				)
			)
		THEN
			UPDATE SET 
			--updated excluding business key
			target.TIMEZONEKEYNAME = source.TIMEZONEKEYNAME,
			target.TimeDif = source.TimeDif,
			target.Deleted = source.Deleted

		WHEN NOT MATCHED BY SOURCE
		THEN 	
		UPDATE SET 
			--set deleted flag to 1
			target.Deleted = 1
			;


	END TRY

	BEGIN CATCH
		/* rollback transaction if there is open transaction */
		IF @@TRANCOUNT > 0	ROLLBACK TRANSACTION

		/* throw the catched error to trigger the error in SSIS package */
		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorNumber INT,
				@ErrorSeverity INT,
				@ErrorState INT,
				@ErrorLine INT,
				@ErrorProcedure NVARCHAR(200)

		/* Assign variables to error-handling functions that capture information for RAISERROR */
		SELECT  @ErrorNumber = ERROR_NUMBER(), @ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(), @ErrorLine = ERROR_LINE(),
			@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ''-'')

		/* Building the message string that will contain original error information */
		SELECT  @ErrorMessage = N''Error %d, Level %d, State %d, Procedure %s, Line %d, ''
		 + ''Message: '' + ERROR_MESSAGE()

		/* Raise an error: msg_str parameter of RAISERROR will contain the original error information */
		RAISERROR (@ErrorMessage, @ErrorSeverity, 1, @ErrorNumber,
			@ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine)
	END CATCH

	--Finally Section
		/* clean up the temporary table */

		IF OBJECT_ID(''tempdb..#SnapShotTable'') IS NOT NULL
			DROP TABLE #SnapShotTable
			
END



' 
END
GO


/****** Object:  UserDefinedFunction [dw].[fn_gettranbucket]    Script Date: 4/07/2014 12:29:02 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[fn_gettranbucket]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dw].[fn_gettranbucket]
GO




/****** Object:  UserDefinedFunction [dw].[fn_gettranbucket]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[fn_gettranbucket]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- split qty on hand in buckets
CREATE FUNCTION [dw].[fn_gettranbucket] (
	@cpnyid NVARCHAR(10)
	,@invtid NVARCHAR(30)
	,@Location NVARCHAR(10)
	,@qty INT
	,@maxdate DATETIME
	)
RETURNS @ntable TABLE (
	cpnyid NVARCHAR(10) NOT NULL
	,invtid NVARCHAR(30) NOT NULL
	,SiteID NVARCHAR(10)NOT NULL
	,bucket01 FLOAT
	,bucket02 FLOAT
	,bucket03 FLOAT
	,bucket04 FLOAT
	,bucket05 FLOAT
	,bucket06 FLOAT
	,bucket07 FLOAT
	,bucket08 FLOAT
	)
AS
BEGIN



	-- Get Partition for company
	DECLARE @partitionid bigint
	SELECT @partitionid = [PARTITION] 
	FROM  [dbo].[DATAAREA]
	WHERE id = @cpnyid

	--define buckets
	DECLARE @tottran INT
		,@posrecordid INT

	DECLARE @AgeingLookUp TABLE (
		[rangeid] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		,[rangest] [int] NULL
		,[rangefn] [int] NULL
		,[rangetext] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''01''
		,0
		,30
		,''1 - 30''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''02''
		,31
		,60
		,''31 - 60''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''03''
		,61
		,90
		,''61 - 90''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''04''
		,91
		,120
		,''91 - 120''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''05''
		,121
		,180
		,''121 - 180''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''06''
		,181
		,270
		,''181 - 270''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''07''
		,271
		,360
		,''271 - 360''
		)

	INSERT INTO @AgeingLookUp (
		[rangeid]
		,[rangest]
		,[rangefn]
		,[rangetext]
		)
	VALUES (
		''08''
		,361
		,32000
		,''361+''
		)

	-- select transactions
	DECLARE @transactions TABLE (
		dataareaid NVARCHAR(8)
		,itemid NVARCHAR(40)
		,SiteID NVARCHAR(40)
		,qty INT
		,datephysical DATE
		,recordid INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
		)

	INSERT INTO @transactions
	SELECT InventTrans.DATAAREAID
		,InventTrans.ITEMID
		,INVENTDIM.INVENTLOCATIONID
		,InventTrans.qty
		,InventTrans.DATEPHYSICAL
	FROM dbo.InventTrans InventTrans WITH (NOLOCK)
	INNER JOIN dbo.INVENTDIM INVENTDIM WITH (NOLOCK)
		ON InventTrans.[PARTITION] = INVENTDIM.[PARTITION]
			AND InventTrans.DATAAREAID = INVENTDIM.DATAAREAID
			AND InventTrans.INVENTDIMID = INVENTDIM.INVENTDIMID
	WHERE InventTrans.[PARTITION] = @partitionid
		AND InventTrans.QTY > 0
		AND InventTrans.DATEPHYSICAL <> ''''
		AND InventTrans.DATAAREAID = @cpnyid
		AND InventTrans.DATEPHYSICAL < = @maxdate
		AND InventTrans.itemid = @invtid
		AND INVENTDIM.INVENTLOCATIONID = @Location
	ORDER BY InventTrans.DATEPHYSICAL DESC

	-- delete transactions not used by aging because acumulated stock is greater than qty on hand
	-- split quantity into ranges using the first in first out method, quantity is based on SOH from InventSum, ageing is derived from InventTrans
	SELECT @tottran = max(recordid)
	FROM @transactions

	SELECT @posrecordid = coalesce(min(recordid), @tottran)
	FROM @transactions AS a
	WHERE (
			SELECT sum(qty)
			FROM @transactions AS b
			WHERE b.recordid <= a.recordid
			) >= @qty

	DELETE
	FROM @transactions
	WHERE recordid > @posrecordid

	IF @posrecordid > 1
		UPDATE @transactions
		SET qty = @qty - (
				SELECT sum(qty)
				FROM @transactions
				WHERE recordid <= @posrecordid - 1
				)
		WHERE recordid = @posrecordid
	ELSE
		UPDATE @transactions
		SET qty = @qty

	DECLARE @sbsantigdet TABLE (
		CPNYID NVARCHAR(10)
		,invtid NVARCHAR(24)
		,SiteID NVARCHAR(40)
		,qty FLOAT
		,rangeid NVARCHAR(2)
		,rangetext NVARCHAR(10)
		)
	-- Allocate ageing id 
	INSERT INTO @sbsantigdet
	SELECT transactions.dataareaid
		, transactions.itemid
		, transactions.SiteID
		, SUM(transactions.qty) AS qty
		, AgeingLookUp.rangeid
		, AgeingLookUp.rangetext
	FROM @transactions AS transactions
	INNER JOIN @AgeingLookUp AgeingLookUp 
		ON 1 = 1
	WHERE DATEDIFF(day, transactions.datephysical, @maxdate) BETWEEN AgeingLookUp.rangest
			AND AgeingLookUp.rangefn
	GROUP BY transactions.dataareaid
		, transactions.itemid
		, transactions.SiteID
		, transactions.qty
		, AgeingLookUp.rangeid
		, AgeingLookUp.rangetext
		, transactions.datephysical

	INSERT INTO @ntable
	SELECT @cpnyid
		,@invtid
		,@Location
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''01''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''02''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''03''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''04''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''05''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''06''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''07''
			)
		,(
			SELECT sum(qty)
			FROM @sbsantigdet AS x
			WHERE x.CPNYID = CPNYID
				AND x.invtid = invtid
				AND x.SiteID = SiteID
				AND x.rangeid = ''08''
			)
	FROM @sbsantigdet
	GROUP BY CPNYID
		,invtid
		,SiteID
	RETURN
END


' 
END

GO
/****** Object:  Table [dw].[SnapshotCompany]    Script Date: 4/07/2014 12:29:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[SnapshotCompany]') AND type in (N'U'))
BEGIN
CREATE TABLE [dw].[SnapshotCompany](
	[CompanyCode] [nvarchar](40) NOT NULL,
	[TIMEZONEKEYNAME] [nvarchar](100) NOT NULL,
	[TimeDif] [nvarchar](20) NULL,
	[LastExtractTimeUTC] [datetime] NULL,
	[NextExtractTimeUTC] [datetime] NOT NULL,
	[LastExtractTimeCompany] [datetime] NULL,
	[NextExtractTimeCompany] [datetime] NOT NULL,
	[Process] [bit] NULL,
	[Deleted] [bit] NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [dw].[WarehouseInventory_SnapShot]    Script Date: 4/07/2014 12:29:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[WarehouseInventory_SnapShot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dw].[WarehouseInventory_SnapShot](
	[WarehouseInventoryDate] [datetime] NOT NULL,
	[DataAreaID] [nvarchar](40) NOT NULL,
	[InventLocationID] [nvarchar](40) NOT NULL,
	[ItemID] [nvarchar](40) NOT NULL,
	[CurrencyCode] [nvarchar](40) NULL,
	[CurrencyEffectiveDate] [datetime] NULL,
	[Price] [money] NULL,
	[PostedQty] [int] NULL,
	[Received] [int] NULL,
	[Deducted] [int] NULL,
	[Registered] [int] NULL,
	[Picked] [int] NULL,
	[PhysicalValue] [money] NULL,
	[PostedValue] [money] NULL,
	[LoadTime] [datetime] NOT NULL,
 CONSTRAINT [PK_WarehouseInventory_SnapShot_PK] PRIMARY KEY CLUSTERED 
(
	[WarehouseInventoryDate] ASC,
	[DataAreaID] ASC,
	[InventLocationID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [dw].[WarehouseInventoryAgeing_SnapShot]    Script Date: 4/07/2014 12:29:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dw].[WarehouseInventoryAgeing_SnapShot]') AND type in (N'U'))
BEGIN
CREATE TABLE [dw].[WarehouseInventoryAgeing_SnapShot](
	[WarehouseInventoryDate] [datetime] NOT NULL,
	[CpnyID] [nvarchar](40) NOT NULL,
	[InvtId] [nvarchar](40) NOT NULL,
	[SiteID] [nvarchar](40) NOT NULL,
	[AgeingId] [nvarchar](40) NOT NULL,
	[CurrencyCode] [nvarchar](40) NULL,
	[CurrencyEffectiveDate] [datetime] NULL,
	[Qty] [int] NULL,
	[Cost] [money] NULL,
	[LoadTime] [datetime] NOT NULL,
 CONSTRAINT [PK_WarehouseInventoryAgeing_SnapShot_PK] PRIMARY KEY CLUSTERED 
(
	[WarehouseInventoryDate] ASC,
	[CpnyID] ASC,
	[InvtId] ASC,
	[SiteID] ASC,
	[AgeingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dw].[DF_WarehouseInventory_SnapShot_LoadTime]') AND type = 'D')
BEGIN
ALTER TABLE [dw].[WarehouseInventory_SnapShot] ADD  CONSTRAINT [DF_WarehouseInventory_SnapShot_LoadTime]  DEFAULT (getdate()) FOR [LoadTime]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dw].[DF_WarehouseInventoryAgeing_SnapShot_LoadTime]') AND type = 'D')
BEGIN
ALTER TABLE [dw].[WarehouseInventoryAgeing_SnapShot] ADD  CONSTRAINT [DF_WarehouseInventoryAgeing_SnapShot_LoadTime]  DEFAULT (getdate()) FOR [LoadTime]
END

GO





USE [msdb]
GO

/****** Object:  Job [DW Stock Data Snapshot]    Script Date: 12/06/2014 11:23:09 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 12/06/2014 11:23:10 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'GDW' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'GDW'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId binary(16)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'GDW Stock Data Snapshot')
IF (@jobId IS NULL)
BEGIN
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GDW Stock Data Snapshot', 
		    @enabled=1, 
		    @notify_level_eventlog=0, 
		    @notify_level_email=0, 
		    @notify_level_netsend=0, 
		    @notify_level_page=0, 
		    @delete_level=0, 
		    @description=N'This SQL job executes the stored procedures to create a snapshot of the inventory data as it is when run. Since the inventory changes and there is no history this is a work around to allow the DW team to get this information without having to restore from several tapes for each day.

** Please see Ryan Hennessy, Stephen Lawson, Dylan Harvery or DW/EIM team for any issues with this SQL job. **

Date: 30 Apr 2014
Author: dharvey (BI Developer).', 
		    @category_name=N'GDW', 
		    @owner_login_name=N'sa', @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    /****** Object:  Step [Load Snapshot Company]    Script Date: 12/06/2014 11:23:12 AM ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Snapshot Company', 
		    @step_id=1, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'EXEC [DW].[LoadSnapshotCompany]', 
		    @database_name=N'<AX_Database_Name, VARCHAR(100), >', 
		    @output_file_name=N'C:\JobLogs\DWStockDataSnapshot______STEP_$(ESCAPE_SQUOTE(STEPID))_LoadSnapshotCompany.txt', 
		    @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    /****** Object:  Step [Load Snapshots]    Script Date: 12/06/2014 11:23:12 AM ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Snapshots', 
		    @step_id=2, 
		    @cmdexec_success_code=0, 
		    @on_success_action=3, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'EXEC [dw].[InsSnapshot_WarehouseInventoryMaster]', 
		    @database_name=N'<AX_Database_Name, VARCHAR(100), >', 
		    @output_file_name=N'C:\JobLogs\DWStockDataSnapshot______STEP_$(ESCAPE_SQUOTE(STEPID))_LoadSnapshots.txt', 
		    @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    /****** Object:  Step [Delete Old Snapshot Data]    Script Date: 12/06/2014 11:23:12 AM ******/
    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete Old Snapshot Data', 
		    @step_id=3, 
		    @cmdexec_success_code=0, 
		    @on_success_action=1, 
		    @on_success_step_id=0, 
		    @on_fail_action=2, 
		    @on_fail_step_id=0, 
		    @retry_attempts=0, 
		    @retry_interval=0, 
		    @os_run_priority=0, @subsystem=N'TSQL', 
		    @command=N'USE [<AX_Database_Name, VARCHAR(100), >]
GO

DECLARE @d AS int

SET @d = 90 -- days

DELETE
FROM [dw].[WarehouseInventory_SnapShot]
WHERE WarehouseInventoryDate < CAST((CONVERT(VARCHAR(8), GETDATE()-@d, 112)) AS DATETIME);

DELETE
FROM [dw].[WarehouseInventoryAgeing_SnapShot]
WHERE WarehouseInventoryDate < CAST((CONVERT(VARCHAR(8), GETDATE()-@d, 112)) AS DATETIME);
--------------------------------------------------------------------------------------
', 
		    @database_name=N'master', 
		    @output_file_name=N'C:\JobLogs\DWStockDataSnapshot______STEP_$(ESCAPE_SQUOTE(STEPID))_DeleteOldSnapshotData.txt', 
		    @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Agent Start Up Schedule', 
		    @enabled=1, 
		    @freq_type=64, 
		    @freq_interval=0, 
		    @freq_subday_type=0, 
		    @freq_subday_interval=0, 
		    @freq_relative_interval=0, 
		    @freq_recurrence_factor=0, 
		    @active_start_date=20140430, 
		    @active_end_date=99991231, 
		    @active_start_time=0, 
		    @active_end_time=235959
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Hourly', 
		    @enabled=1, 
		    @freq_type=4, 
		    @freq_interval=1, 
		    @freq_subday_type=8, 
		    @freq_subday_interval=1, 
		    @freq_relative_interval=0, 
		    @freq_recurrence_factor=0, 
		    @active_start_date=20140430, 
		    @active_end_date=99991231, 
		    @active_start_time=0, 
		    @active_end_time=235959
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO