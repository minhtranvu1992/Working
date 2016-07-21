USE [MetadataDB_JR]
GO
/****** Object:  StoredProcedure [dbo].[uspScriptDWDeliveryProcs]    Script Date: 7/21/2016 9:35:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	DECLARE @Environment AS VARCHAR(100) = 'Model'
	DECLARE @DWExtract_ModelDB AS VARCHAR(100)='DWJRExtract_Model'


SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @LayerType AS VARCHAR(50)
		DECLARE @Schema AS VARCHAR(50)
		DECLARE @Version AS VARCHAR(50)
		SET @Version = 'DEV' -- should be set to DEV or TEST (DEV will create default values for mandatory fields on fact loads)

		DECLARE @Sql_Proc_Name AS VARCHAR(MAX) = ''
		DECLARE @Sql_Proc_Header AS VARCHAR(MAX) = ''
		DECLARE @Sql_Proc_Middle AS VARCHAR(MAX) = ''	
		DECLARE @Sql_Proc_Footer AS VARCHAR(MAX) = ''
		DECLARE @Sql_Proc AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_ExtendedProps AS VARCHAR(MAX) = ''
		
		--Declare layer object variables
		DECLARE @ETLType AS VARCHAR(MAX)
		DECLARE @SourceEntity AS VARCHAR(MAX)
		DECLARE @SourceTable AS VARCHAR(MAX)
		DECLARE @ETLEntity AS VARCHAR(MAX)
		DECLARE @DestEntity AS VARCHAR(MAX)
		DECLARE @SourceEntityID AS VARCHAR(MAX)
		DECLARE @DestEntityID AS VARCHAR(MAX)
		DECLARE @DestTable AS VARCHAR(MAX)
		DECLARE @DestType AS VARCHAR(MAX)
		DECLARE @DimBK AS VARCHAR(MAX)
		DECLARE @InfSourceBK AS VARCHAR(MAX)
		DECLARE @InfDestBK AS VARCHAR(MAX)
		DECLARE @InfSourceSK AS VARCHAR(MAX)
		DECLARE @InfDestSK AS VARCHAR(MAX)
		DECLARE @SourceLayerID AS VARCHAR(MAX)
		DECLARE @DestLayerID AS VARCHAR(MAX)
		DECLARE @SnapshotProcessSeperator AS VARCHAR(MAX)

		DECLARE @SourceColumn AS VARCHAR(MAX)
		DECLARE @SourceDataType AS VARCHAR(MAX)
		DECLARE @BusinessKeyOrder AS VARCHAR(MAX)
		DECLARE @LastBusinessKeyOrder AS VARCHAR(MAX)
		DECLARE @DestColumn AS VARCHAR(MAX)
		DECLARE @SourceColumnList1 AS VARCHAR(MAX) = ''
		DECLARE @SourceColumnList2 AS VARCHAR(MAX) = ''
		DECLARE @SourceColumnList3 AS VARCHAR(MAX) = ''
		DECLARE @SourceColumnList4 AS VARCHAR(MAX) = ''
		DECLARE @DestColumnList1 AS VARCHAR(MAX) = ''
		DECLARE @DestColumnList2 AS VARCHAR(MAX) = ''
		DECLARE @HashTargetList AS VARCHAR(MAX) = ''
		DECLARE @HashSourceList AS VARCHAR(MAX) = ''
		DECLARE @TargetToSourceBK AS VARCHAR(MAX) = ''
		DECLARE @TargetToSourceExBK AS VARCHAR(MAX) = ''
		DECLARE @TargetToSourceExBK2 AS VARCHAR(MAX) = ''
		DECLARE @TargetToSourceExBK3 AS VARCHAR(MAX) = ''
		DECLARE @SourceErrToExtBK AS VARCHAR(MAX)	 = ''
		DECLARE @ForeignKeyEntity AS VARCHAR(MAX) = ''
		DECLARE @ForeignKeyLayerID AS VARCHAR(MAX) = ''
		DECLARE @ForeignKeyAlias AS VARCHAR(MAX) = ''
		DECLARE @ValidateSurrogateKeys AS VARCHAR(MAX) = ''
		DECLARE @SourceBusinessKey AS VARCHAR(MAX)
		DECLARE @ForeignKeyTable AS VARCHAR(MAX)
		DECLARE @ForeignKeyField AS VARCHAR(MAX)
		DECLARE @ForeignSurrogateKeyField AS VARCHAR(MAX) = ''
		DECLARE @ForeignBusinessKeyField AS VARCHAR(MAX) = ''
		DECLARE @ForeignKeyTableJoin AS VARCHAR(MAX) = ''
		DECLARE @DestBusinessKey AS VARCHAR(MAX)
		DECLARE @ForeignKeyFieldList1 AS VARCHAR(MAX) = ''
		DECLARE @ForeignKeyFieldList2 AS VARCHAR(MAX) = ''
		DECLARE @ErrSKList AS VARCHAR(MAX) = ''
		DECLARE @ErrMessage AS VARCHAR(MAX) = ''
		DECLARE @InvalidErrorCount AS INT = 0
		DECLARE @MissingErrorCount AS INT = 0
		DECLARE @RetainBusinessKey AS INT = 0
		DECLARE @ErrorOnInvalidBusinessKey AS INT = 0
		DECLARE @ErrorOnMissingBusinessKey AS INT = 0

		-- Declare variables for delete process
		DECLARE @NotMatchedBySourceBK AS VARCHAR(MAX) = ''
		DECLARE @GetSourceCompanyCodeScript AS VARCHAR(MAX) 
	
		if object_id ('tempdb..#ETL' ) is not null
		   DROP TABLE #ETL

		CREATE TABLE #ETL (
			ETLType nvarchar(40) NOT NULL,
			SourceEntity nvarchar(100) NOT NULL, 
			DestEntity nvarchar(100) NOT NULL,
			SourceEntityID nvarchar(100) NOT NULL, 
			DestEntityID nvarchar(100) NOT NULL,
			DestTable nvarchar(100) NOT NULL,
			DestType nvarchar(100) NOT NULL,
			InfSourceBK nvarchar(100) NULL,
			InfDestBK nvarchar(100) NULL,
			InfSourceSK nvarchar(100) NULL,
			InfDestSK nvarchar(100) NULL,
			DimBK nvarchar(100) NULL,
			SourceTable nvarchar(100) NULL,
			SourceLayerID nvarchar(100) NULL,
			DestLayerID nvarchar(100) NULL,
			SnapshotProcessSeperator nvarchar(100) NULL,
			DWObjectLoadLogic varchar(40) NULL,

		) 

		if object_id ('tempdb..#ETLElements' ) is not null
		   DROP TABLE #ETLElements

		CREATE TABLE #ETLElements (
			ElementOrder int NOT NULL,
			SourceColumn nvarchar(100) NOT NULL,
			BusinessKeyOrder int NULL,
			SourceDataType nvarchar(100) NOT NULL,
			DestColumn nvarchar(100) NOT NULL,
			ForeignKeyEntity nvarchar(100) NULL, 
			ForeignKeyLayerID nvarchar(100) NULL,
			ForeignKeyAlias nvarchar(100) NULL,
			ForeignSurrogateKeyField nvarchar(100) NULL,
			ForeignBusinessKeyField nvarchar(100) NULL,
			RetainBusinessKey int NULL,
			ErrorOnInvalidBusinessKey int NULL,
			ErrorOnMissingBusinessKey int NULL
		)

		CREATE CLUSTERED INDEX CIX_#ETLElements ON #ETLElements (ElementOrder ASC)

		--insert Type1 Dimension Load Objects into table.
		INSERT INTO #ETL
		SELECT
			DWObjectType.DWObjectTypeID AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject.DWObjectID AS DestEntityID,
			DWLayer.DWLayerAbbreviation + '.' + 'Dim' + DWOBject.DWObjectName AS DestTable,
			'Dim' AS DestType,
			'' AS InfSourceBK,
			'' AS InfDestBK,
			'' AS InfSourceSK,
			'' AS InfDestSK,
			'' AS DimBK,
			'ext_' + DWObject.DWLayerID + '.' + DWOBject.DWObjectName AS SourceTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject.DWLayerID AS DestLayerID,
			'' AS SnapshotProcessSeperator,
			DWObjectType.DWObjectLoadLogic -- Added
		FROM dbo.DWOBject DWOBject
			INNER JOIN dbo.DWObjectType DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
		WHERE DWLayerType = 'Base' AND 
			DWObject.DWObjectTypeID IN ('DIM-SCD1') and IncludeInBuild = 1  
		ORDER BY DWObject.DWLayerID, DWObject.DWObjectName
		-------------------------------------------------------------------------------------------------
		select * from #ETL
		-------------------------------------------------------------------------------------------------

		--insert Inferred Member Loads into table.
		INSERT INTO #ETL
		SELECT
			'InferredMemberLoad' AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWObject2.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWObject2.DWObjectID AS DestEntityID,
			DWLayer2.DWLayerAbbreviation + '.' + 'Dim' + DWOBject2.DWObjectName AS DestTable,
			'Dim' AS DestType,
			DWElement.DWElementName AS InfSourceBK,
			DWElement2.DWElementName AS InfDestBK,
			(CASE WHEN DWElement.DWElementName LIKE '%ID' THEN REPLACE(DWElement.DWElementName, 'ID', 'SK') ELSE DWElement.DWElementName + 'SK' END ) AS InfSourceSK,
			(CASE WHEN DWElement2.DWElementName LIKE '%ID' THEN REPLACE(DWElement2.DWElementName, 'ID', 'SK') ELSE DWElement2.DWElementName + 'SK' END ) AS InfDestSK,
			'' AS DimBK,
			'ext_' + DWObject.DWLayerID + '.' + DWOBject.DWObjectName AS SourceTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject2.DWLayerID AS DestLayerID,
			'' AS SnapshotProcessSeperator,
			DWObjectType.DWObjectLoadLogic -- Added
		FROM dbo.DWOBject DWOBject
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWElement DWElement ON 
				DWOBject.DWObjectID = DWElement.DWObjectID
			LEFT JOIN dbo.DWOBject DWOBject2 ON  
				DWElement.EntityLookupObjectID = DWOBject2.DWObjectID
			LEFT JOIN dbo.DWLayer DWLayer2 
				ON DWObject2.DWLayerID = DWLayer2.DWLayerID
			LEFT JOIN dbo.DWElement DWElement2 ON  
				DWOBject2.DWObjectID = DWElement2.DWObjectID 
				AND DWElement2.BusinessKeyOrder = 1
		WHERE   
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('FACT-ACCUMULATING', 'FACT-SNAPSHOTHIST', 'FACT-SNAPSHOT', 'REF-CHANGING-FACT') and 
			DWOBject.IncludeInBuild = 1 AND DWElement.InferredMemberLoad = 1 AND DWOBject2.DWObjectID IS NOT NULL 
			
		-------------------------------------------------------------------------------------------------
		select * from #ETL
		-------------------------------------------------------------------------------------------------
			 
		
		--insert SnowFlake Member Loads into table.
		INSERT INTO #ETL
		SELECT
			'SnowFlakeMemberLoad' AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject2.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject2.DWObjectID AS DestEntityID,
			DWLayer2.DWLayerAbbreviation + '.' + 'Dim' + DWOBject2.DWObjectName AS DestTable,
			'Dim' AS DestType,
			DWElement.DWElementName AS InfSourceBK,
			DWElement2.DWElementName AS InfDestBK,
			(CASE 
				WHEN DWElement.DWElementName = DWElement3.DWElementName 
					THEN DWLayer2.DWLayerID
				ELSE ''
			END) +
			(CASE WHEN DWElement.DWElementName LIKE '%ID' THEN REPLACE(DWElement.DWElementName, 'ID', 'SK') ELSE DWElement.DWElementName + 'SK' END ) AS InfSourceSK,
			(CASE WHEN DWElement2.DWElementName LIKE '%ID' THEN REPLACE(DWElement2.DWElementName, 'ID', 'SK') ELSE DWElement2.DWElementName + 'SK' END ) AS InfDestSK,
			DWElement3.DWElementName AS DimBK,
			DWLayer.DWLayerAbbreviation + '.' + 'Dim' + DWOBject.DWObjectName AS SourceTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject2.DWLayerID AS DestLayerID,
			'' AS SnapshotProcessSeperator
			,DWObjectType.DWObjectLoadLogic --Added
		FROM dbo.DWOBject DWOBject	
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWElement DWElement ON 
				DWOBject.DWObjectID = DWElement.DWObjectID
			LEFT JOIN dbo.DWOBject DWOBject2 ON 
				DWElement.EntityLookupObjectID = DWOBject2.DWObjectID
			LEFT JOIN dbo.DWLayer DWLayer2 
				ON DWObject2.DWLayerID = DWLayer2.DWLayerID
			LEFT JOIN dbo.DWElement DWElement2 ON  
				DWOBject2.DWObjectID = DWElement2.DWObjectID 
				AND DWElement2.BusinessKeyOrder = 1
			LEFT JOIN dbo.DWElement DWElement3 
				ON DWElement3.DWObjectID = DWOBject.DWObjectID 
				AND DWElement3.BusinessKeyOrder = 1
		WHERE  
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('DIM-SCD1', 'DIM-SCD2') 
			AND DWOBject.IncludeInBuild = 1 AND DWElement.InferredMemberLoad = 1 AND DWOBject2.DWObjectID IS NOT NULL  
			
			-------------------------------------------------------------------------------------------------
		select * from #ETL
		-------------------------------------------------------------------------------------------------		
	
		--insert Fact \ Bridge Loads into table.
		INSERT INTO #ETL
		SELECT
			DWOBject.DWObjectTypeID AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject.DWObjectID AS DestEntityID,
			DWLayer.DWLayerAbbreviation + '.' + (CASE WHEN DWOBject.DWObjectTypeID LIKE '%fact%' THEN 'Fact' WHEN DWOBject.DWObjectTypeID LIKE '%Bridge%' THEN 'Dim' ELSE '' END) + DWOBject.DWObjectName  AS DestTable,
			(CASE WHEN DWOBject.DWObjectTypeID LIKE '%fact%' THEN 'Fact' WHEN DWOBject.DWObjectTypeID LIKE '%Bridge%' THEN 'Dim' ELSE '' END) AS DestType,
			'' AS InfSourceBK,
			'' AS InfDestBK,
			'' AS InfSourceSK,
			'' AS InfDestSK,
			'' AS DimBK,
			'ext_' + DWObject.DWLayerID + '.' + DWOBject.DWObjectName AS SourceTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject.DWLayerID AS DestLayerID,
			COALESCE(SnapshotSeperator.DWElementName, '') AS SnapshotProcessSeperator,
			DWObjectType.DWObjectLoadLogic -- Added
		FROM dbo.DWOBject DWOBject	
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			LEFT JOIN 
				(SELECT DWObjectID, MAX(DWElementName) AS DWElementName 
				FROM dbo.DWElement DWElement
				WHERE SnapshotProcessSeperator = 1
				GROUP BY DWObjectID) SnapshotSeperator
				ON  DWOBject.DWObjectID = SnapshotSeperator.DWObjectID
				AND DWOBject.DWObjectTypeID = 'FACT-SNAPSHOT' 
		WHERE 
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('FACT-SNAPSHOT', 'FACT-TRANSACTION', 'FACT-SNAPSHOTHIST', 'FACT-ACCUMULATING', 'DIM-SCD2-BRIDGE', 'DIM-SCD1-BRIDGE')  AND IncludeInBuild = 1
		ORDER BY DWObjectName
		-------------------------------------------------------------------------------------------------
		select * from #ETL
		-------------------------------------------------------------------------------------------------

		WHILE (SELECT COUNT(*) FROM #ETL) > 0
		BEGIN
			SELECT TOP 1 
				@ETLType = ETLType,
				@SourceEntity = SourceEntity,
				@DestEntity = DestEntity,
				@SourceEntityID = SourceEntityID,
				@DestEntityID = DestEntityID,
				@DestTable = DestTable,
				@DestType = DestType,
				@InfSourceBK = InfSourceBK,
				@InfDestBK = InfDestBK,
				@InfSourceSK = InfSourceSK,
				@InfDestSK = InfDestSK,
				@DimBK = DimBK,
				@SourceTable = SourceTable,
				@SourceLayerID = SourceLayerID,
				@DestLayerID = DestLayerID,
				@SnapshotProcessSeperator = SnapshotProcessSeperator
			FROM #ETL 
			Order By DestEntityID, SourceEntityID, InfSourceBK
			
			--Load Layer Element Metadata
			DELETE FROM #ETLElements 

			--Load Extract Layer element metadata into temp table
			INSERT INTO #ETLElements (ElementOrder, SourceColumn, BusinessKeyOrder, SourceDataType, --IsMandatory, 
				DestColumn, 
				ForeignKeyEntity, ForeignKeyLayerID, ForeignKeyAlias, ForeignSurrogateKeyField, ForeignBusinessKeyField, RetainBusinessKey, ErrorOnInvalidBusinessKey, ErrorOnMissingBusinessKey)
			SELECT 
				ElementOrder,
				DWElement.DWElementName AS SourceColumn,
				DWElement.BusinessKeyOrder,
				DWElement.DataType AS SourceDataType,
				(CASE 
					WHEN (@ETLType IN ('FACT-SNAPSHOT', 'FACT-TRANSACTION', 'FACT-SNAPSHOTHIST', 'FACT-ACCUMULATING', 'DIM-SCD2-BRIDGE', 'DIM-SCD1-BRIDGE')) AND (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.BusinessKeyOrder = 1) AND @DestType = 'Dim'
						THEN REPLACE(DWElement.DWElementName,'ID','SK')
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.BusinessKeyOrder = 1) AND @DestType = 'Dim'
						THEN DWElement.DWElementName
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.DWElementName LIKE '%ID')
						THEN REPLACE(DWElement.DWElementName,'ID','SK') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.DWElementName LIKE '%Datetime')
						THEN REPLACE(DWElement.DWElementName,'Datetime','DateID') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.DWElementName LIKE '%Date')
						THEN REPLACE(DWElement.DWElementName,'Date','DateID') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField NOT LIKE '%ID')
						THEN DWElement.ForeignBusinessKeyField + 'SK'
					ELSE DWElement.DWElementName
				END) AS DestColumn,
				DWElement.ForeignKeyEntity, 
				DWElement.ForeignKeyLayerID,
				(CASE 
					WHEN (DWElement.ForeignKeyEntity IS NOT NULL) 
						THEN REPLACE(DWElement.DWElementName, 'ID', '') 
					ELSE NULL
				END)	AS ForeignKeyAlias,
				(CASE 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField LIKE '%DateID')
						THEN DWElement.ForeignBusinessKeyField 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField LIKE '%ID')
						THEN REPLACE(DWElement.ForeignBusinessKeyField,'ID','SK') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField LIKE '%Datetime')
						THEN REPLACE(DWElement.ForeignBusinessKeyField,'Datetime','DateID') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField LIKE '%Date')
						THEN REPLACE(DWElement.ForeignBusinessKeyField,'Date','DateID') 
					WHEN (DWElement.EntityLookupObjectID IS NOT NULL) AND (DWElement.ForeignBusinessKeyField NOT LIKE '%ID')
						THEN DWElement.ForeignBusinessKeyField + 'SK'
					ELSE NULL
				END) AS ForeignSurrogateKeyField,
				DWElement.ForeignBusinessKeyField,
				DWElement.RetainBusinessKey,
				DWElement.ErrorOnInvalidBusinessKey,
				DWElement.ErrorOnMissingBusinessKey
			FROM
				(SELECT 
					DWElement.DWElementName,
					DWElement.BusinessKeyOrder,
					DomainDataType.DataType,
					DWElement.EntityLookupObjectID,
					DWElement.RetainBusinessKey,
					DWElement.ErrorOnInvalidBusinessKey,
					DWElement.ErrorOnMissingBusinessKey,			
					DWElement2.DWElementName AS ForeignBusinessKeyField, 
					EntityLookupObject.DWObjectName AS ForeignKeyEntity,
					EntityLookupObject.DWLayerID AS ForeignKeyLayerID,
					ROW_NUMBER() OVER (PARTITION BY DWElement.DWObjectID ORDER BY COALESCE(DWElement.BusinessKeyOrder, 999), DWElement.DWElementName) AS ElementOrder
				FROM dbo.DWElement DWElement
					INNER JOIN dbo.DomainDataType DomainDataType
						ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
					LEFT JOIN dbo.DWObject EntityLookupObject
						ON DWElement.EntityLookupObjectID = EntityLookupObject.DWObjectID
					LEFT JOIN dbo.DWElement  DWElement2
						ON DWElement2.BusinessKeyOrder = 1 
						AND EntityLookupObject.DWObjectID = DWElement2.DWObjectID
				WHERE 
					DWElement.DWObjectID = @SourceEntityID) DWElement

		-------------------------------------------------------------------------------------------------
		select * from #ETLElements
		-------------------------------------------------------------------------------------------------
					
			WHILE (SELECT COUNT(*) FROM #ETLElements) > 0
			BEGIN
				SELECT TOP 1 
					@SourceColumn = COALESCE(SourceColumn,''),
					@SourceDataType = COALESCE(SourceDataType,''),
					@BusinessKeyOrder = COALESCE(BusinessKeyOrder, 999),
					@DestColumn = DestColumn,
					@ForeignKeyEntity = COALESCE(ForeignKeyEntity,''),
					@ForeignKeyLayerID = COALESCE(ForeignKeyLayerID,''),
					@ForeignKeyAlias = COALESCE(ForeignKeyAlias,''),
					@ForeignBusinessKeyField = COALESCE(ForeignBusinessKeyField,''),
					@ForeignSurrogateKeyField = COALESCE(ForeignSurrogateKeyField,''),
					@RetainBusinessKey = COALESCE(RetainBusinessKey, 0),
					@ErrorOnInvalidBusinessKey = COALESCE(ErrorOnInvalidBusinessKey, 0),
					@ErrorOnMissingBusinessKey = COALESCE(ErrorOnMissingBusinessKey, 0)
				FROM #ETLElements 				
			
				SELECT	@SourceColumnList1 = @SourceColumnList1 + @SourceColumn + ',
			'
				SELECT  @SourceColumnList2 = @SourceColumnList2 + 'Source.' + @SourceColumn + ',
			'
				SELECT	@SourceColumnList3 = @SourceColumnList3 + 'ext.' + @SourceColumn + ',
			'		
				
				SELECT  @SourceColumnList4 = @SourceColumnList4 + 
					(CASE 
						WHEN (@SourceDataType IN ('Date', 'Datetime') AND @ForeignKeyEntity = 'Date') 
							THEN 'CAST(CONVERT(CHAR(8), ' + @SourceColumn + ', 112) AS INT) AS ' + @SourceColumn + 'ID'
						ELSE @DestColumn
					END) + ',
			'

				SELECT  @DestColumnList1 = @DestColumnList1 +  @DestColumn + ',
			'
				SELECT  @DestColumnList2 = @DestColumnList2 + 'Source.' + @DestColumn + ',
			'

				--Add extra columns to @DestColumnList1 and @DestColumnList2 if we are retaining the business keys as well as adding surrogate keys
				IF (@RetainBusinessKey = 1)
				BEGIN
					SELECT  @SourceColumnList4 = @SourceColumnList4 + @SourceColumn + ',
				'
					SELECT  @DestColumnList1 = @DestColumnList1 + @SourceColumn + ',
			'
					SELECT  @DestColumnList2 = @DestColumnList2 + 'Source.' + @SourceColumn + ',
			'
				END

				--Build text strings that include business keys
				IF (@BusinessKeyOrder = 1)
				BEGIN
					SELECT  @SourceErrToExtBK = @SourceErrToExtBK + 'Err.' + @SourceColumn + ' = Ext.' + @SourceColumn + '
				'	
					SELECT  @TargetToSourceBK = @TargetToSourceBK + '
			(target.' + @DestColumn + ' = source.' + @DestColumn + ')'

			       
				   -- Generate filter condition based on business key for NOT MATCHED BY SOURCE 
					SELECT @NotMatchedBySourceBK = 
							CASE
								WHEN @ETLType IN ('DIM-SCD1') AND (SELECT COUNT(*) FROM #ETLElements WHERE DestColumn ='CompanyCode') >0
										THEN  
										'AND target.CompanyCode in ( select CompanyCode from #ExtSourceIdentifier)
										'
								ELSE ''
							END

					-- Generate script to get value of Business key
					SELECT @GetSourceCompanyCodeScript = 
					CASE
						WHEN @ETLType IN ('DIM-SCD1') AND (SELECT COUNT(*) FROM #ETLElements WHERE DestColumn='CompanyCode') >0
								THEN  
		'CompanyCode'
						ELSE null
					END

					
					
				END
				ELSE IF (@BusinessKeyOrder < 999)
				BEGIN
					SELECT  @SourceErrToExtBK = @SourceErrToExtBK + 'AND Err.' + @SourceColumn + ' = Ext.' + @SourceColumn + ' 
				'	
					SELECT  @TargetToSourceBK =  @TargetToSourceBK + '
			AND (target.' + @DestColumn + ' = source.' + @DestColumn + ')'
				END
				
				--Build those text strings that exclude business keys
				--test if this column is not a business key

				IF (@BusinessKeyOrder = 999)
				BEGIN
					--test if last column was a business key
					IF (@LastBusinessKeyOrder < 999)
					BEGIN
						SELECT  @TargetToSourceExBK = @TargetToSourceExBK + '
			(target.' + @SourceColumn + ' = source.' + @SourceColumn + ')'	
						SELECT  @HashTargetList = @HashTargetList + '
					COALESCE(RTRIM(CAST(target.' + @SourceColumn + ' AS nvarchar(100))),'''')'
						SELECT  @HashSourceList = @HashSourceList + '
					COALESCE(RTRIM(CAST(source.' + @SourceColumn + ' AS nvarchar(100))),'''')'
					END
					ELSE
					BEGIN
						SELECT  @TargetToSourceExBK = @TargetToSourceExBK + '
			AND (target.' + @SourceColumn + ' = source.' + @SourceColumn + ')'	
						SELECT  @HashTargetList = @HashTargetList + '
					+ COALESCE(RTRIM(CAST(target.' + @SourceColumn + ' AS nvarchar(100))),'''')'
						SELECT  @HashSourceList = @HashSourceList + '
					+ COALESCE(RTRIM(CAST(source.' + @SourceColumn + ' AS nvarchar(100))),'''')'
					END

					SELECT  @TargetToSourceExBK2 = @TargetToSourceExBK2 + '
			target.' + @SourceColumn + ' = source.' +  @SourceColumn + ','	

					SELECT  @TargetToSourceExBK3 = @TargetToSourceExBK3 + @DestColumn + ' = Source.' + @DestColumn +  ',
				'			
				
				--Add extra columns to @TargetToSourceExBK3 if we are retaining the business keys as well as adding surrogate keys
					IF (@RetainBusinessKey = 1)
					BEGIN	
						SELECT  @TargetToSourceExBK3 = @TargetToSourceExBK3 + @SourceColumn + ' = Source.' + @SourceColumn +  ',
				'										
					END											
				END				

				--Build those text strings that rely on foreign key columns
				IF 	(@ForeignKeyEntity <> '' AND @ForeignKeyEntity <> 'Date') 
				BEGIN
			
					--ValidateSurrogateKeys string
					SELECT  @ValidateSurrogateKeys = @ValidateSurrogateKeys + ',
			(CASE WHEN ' + 
						(CASE 
							WHEN @SourceDataType LIKE '%char%' THEN 'COALESCE(ext.' + @SourceColumn + ', '''') = '''' '  
							ELSE 'ext.' + @SourceColumn + ' IS NULL' 
						END) + ' THEN -1 ELSE COALESCE(' + @ForeignKeyAlias + '.' + @ForeignSurrogateKeyField + ', -2) END) AS ' + @DestColumn 

					--ForeignKeyTableJoin string
					SELECT @ForeignKeyTableJoin = @ForeignKeyTableJoin + '
			LEFT JOIN dw_' + @ForeignKeyLayerID + '.Dim' + @ForeignKeyEntity + ' AS ' + @ForeignKeyAlias + ' (NOLOCK) 
				ON ' + (CASE WHEN @ForeignKeyEntity = 'Date' THEN 'CAST(ext.' + @SourceColumn + ' AS DATE)' ELSE 'ext.' + @SourceColumn END) + ' = ' + @ForeignKeyAlias + '.' + @ForeignBusinessKeyField

					--Build Error Logic for Foreign Keys based on whether there is a surrogate key lookup
					--and whether an error on InvalidBusiness or MissingbusinessKey is specified

					--Check if either error condition is true
					If (@ErrorOnInvalidBusinessKey = 1 OR @ErrorOnMissingBusinessKey = 1) 
					BEGIN

						IF (@ErrorOnInvalidBusinessKey = 1 AND @ErrorOnMissingBusinessKey = 1)
						BEGIN
							SELECT @InvalidErrorCount = @InvalidErrorCount + 1
							SELECT @MissingErrorCount = @MissingErrorCount + 1
							SELECT @ErrSKList = '-1, -2'
						END
						ELSE IF (@ErrorOnInvalidBusinessKey = 1)
						BEGIN
							SELECT @InvalidErrorCount = @InvalidErrorCount + 1
							SELECT @ErrSKList = '-2'
						END
						ELSE IF (@ErrorOnMissingBusinessKey = 1)
						BEGIN
							SELECT @MissingErrorCount = @MissingErrorCount + 1
							SELECT @ErrSKList = '-1'
						END
						
						IF (@ErrorOnInvalidBusinessKey = 1 AND @InvalidErrorCount = 1)
							SELECT @ForeignKeyFieldList2 = @ForeignKeyFieldList2 + '(' + @DestColumn + ' = -2) '
						ELSE IF (@ErrorOnInvalidBusinessKey = 1) 
							SELECT @ForeignKeyFieldList2 = @ForeignKeyFieldList2 + ' OR (' + @DestColumn + ' = -2)'

						IF (@ErrorOnMissingBusinessKey = 1 AND @MissingErrorCount = 1)
							SELECT @ForeignKeyFieldList1 = @ForeignKeyFieldList1 + '(' + @DestColumn + ' = -1) '
						ELSE IF (@ErrorOnMissingBusinessKey = 1) 
							SELECT @ForeignKeyFieldList1 = @ForeignKeyFieldList1 + ' OR (' + @DestColumn + ' = -1)'

						IF (@MissingErrorCount > 1 OR  @InvalidErrorCount > 1)
							SELECT @ErrMessage = @ErrMessage +  ' +	 '

						SELECT @ErrMessage = @ErrMessage + '
						(CASE 
							WHEN ' + @DestColumn + ' IN (' + @ErrSKList  + ')
								THEN '' : '' + ''' + @SourceColumn + ' = '' + ' + ' CAST(COALESCE(cteLookup.' + @SourceColumn + ','''') AS NVARCHAR(100)) 
							ELSE '''' 
						END)'

					END
				END
	
				SELECT @LastBusinessKeyOrder = @BusinessKeyOrder
				--Delete processed row from tablelist
				DELETE TOP (1) FROM #ETLElements 
			END

			SELECT @ETLEntity = (CASE WHEN @ETLType IN ('InferredMemberLoad','SnowFlakeMemberLoad') THEN REPLACE(@InfSourceBK, 'ID', '') ELSE @DestEntity END) +  
				(CASE WHEN @ETLType IN ('InferredMemberLoad','SnowFlakeMemberLoad') THEN 'From' + @SourceEntity ELSE '' END)
 
			SELECT @Sql_Proc_Name = 'uspDeliver_' + @DestLayerID + @DestType + @ETLEntity 

			--Build Proc Header
			SELECT @Sql_Proc_Header = '
PRINT N''Dropping Procedure dbo.' + @Sql_Proc_Name + '...''
GO
				
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''dbo.' + @Sql_Proc_Name + ''') AND type in (N''P'', N''PC''))
DROP PROCEDURE dbo.' + @Sql_Proc_Name + '
GO				
				
PRINT N''Creating Procedure dbo.' + @Sql_Proc_Name + '...''
GO
				
/****** Object:  StoredProcedure dbo.' + @Sql_Proc_Name + '    Script Date: 04/14/2012 00:20:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================================
-- *** CREATED FROM Metadata, TO CHANGE UPDATE Metadata in Solution AND RECREATE ***
-- Author:		Metadata
-- Description:	This stored procedure delivers the data from table ' + (CASE WHEN @ETLType = 'SnowFlakeMemberLoad' THEN @SourceTable ELSE 'Ext' + @SourceEntity END) + '
--				to ' + @DestTable + '
--
-- ====================================================================================
CREATE PROCEDURE dbo.' + @Sql_Proc_Name + '
(
	@ExtractJobID INT
	,@DeliveryJobID INT
	,@IsDeleteOffsetSchedule INT = 0
	,@SourceHitDeleteOffsetXML NVARCHAR(MAX) = NULL
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

	BEGIN TRY

		/* drop the temporary table if exists */
		IF OBJECT_ID(''tempdb..#Ext' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Ext' + @ETLEntity + '
' + 
			(CASE 
				WHEN @ETLType IN ('FACT-TRANSACTION', 'FACT-SNAPSHOT', 'FACT-SNAPSHOTHIST', 'Dim-Bridge')  THEN
'
		IF OBJECT_ID(''tempdb..#Err' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Err' + @ETLEntity + '

		IF OBJECT_ID(''tempdb..#Validated' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Validated' + @ETLEntity
				ELSE
		''
			END) + 
			(CASE 
				WHEN @ETLType IN ('FACT-SNAPSHOT') AND @SnapshotProcessSeperator <> '' THEN
'

		IF OBJECT_ID(''tempdb..#' + @SnapshotProcessSeperator + ''') IS NOT NULL
			DROP TABLE #' + @SnapshotProcessSeperator + '

		DECLARE @Current' + @SnapshotProcessSeperator + ' AS NVARCHAR(40)
'
        			ELSE
		''
			END) + '

		/* select the rows based on ExtractJobID into temporary table */
'


			
		--Build Proc Middle
			SELECT @Sql_Proc_Middle = 
				(CASE 
					WHEN @ETLType LIKE 'DIM-SCD1' THEN
					
(
                       
'		
        SELECT
			' + @SourceColumnList1 + 
			'ExtractJobID
		INTO #Ext' + @ETLEntity + '
		FROM ext_' + @SourceLayerID + '.' + @SourceEntity + ' (NOLOCK)
		WHERE 
			ExtractJobID = @ExtractJobID 

	
'+
			   CASE
			         WHEN @GetSourceCompanyCodeScript is not null 
					 THEN 
'
		IF object_Id(''tempdb..#ExtSourceIdentifier'') IS NOT NULL
		DROP TABLE #ExtSourceIdentifier

		-- Get CompanyCode from source, used for delete process checking

		SELECT TOP 1 '+ isnull(@GetSourceCompanyCodeScript,'')+'
		INTO #ExtSourceIdentifier
		FROM #Ext' + @ETLEntity + '
'      
                     ELSE '' END
+
'
		/* merge the records (insert new rows and update existing rows) */
		MERGE ' + @DestTable + ' AS target
		USING 
		(
		SELECT 
			' + @SourceColumnList1 + 
			'ExtractJobID
		FROM #Ext' + @ETLEntity + '
		) AS source 
		(
			' + @SourceColumnList1 + 
			'ExtractJobID
		)
		ON 
		(' +	@TargetToSourceBK + '
		)
		WHEN NOT MATCHED THEN 
		INSERT (
			' + @SourceColumnList1 + 
			'SourceIdentifier,
			LastUpdateTime,
			ExtractJobID,
			DeliveryJobID
		)
		VALUES
		(
			' + @SourceColumnList2 + 
			'''' + @SourceLayerID + '_' + @SourceEntity + ''', 
			GETDATE(), 
			ExtractJobID,
			@DeliveryJobID
		)
		WHEN MATCHED AND 
			--compare excluding business key
			(	
				HASHBYTES(''MD5'','	+ @HashTargetList +	'		
				)
				<>
				HASHBYTES(''MD5'',' + @HashSourceList + '
				)
			)
		THEN
			UPDATE SET 
			--updated excluding business key' + @TargetToSourceExBK2 + '	
			Target.SourceIdentifier = ''' + @SourceLayerID + '_' + @SourceEntity + ''', 
			Target.LastUpdateTime = GETDATE(), 
			Target.ExtractJobID = source.ExtractJobID,
			Target.DeliveryJobID = @DeliveryJobID,
			Target.DeletedFlag = 0

	    -- Update DeletedFlag = 1 for rows in base layer which have source was deleted based on IsDeleteOffsetSchedule, ExtractStartTime and Business key
		WHEN NOT MATCHED BY source 
		                           AND (@IsDeleteOffsetSchedule = 1) 
								   AND Target.SourceIdentifier = ''' + @SourceLayerID + '_' + @SourceEntity + '''
								   AND target.SourceIdentifier <> ''Metadata''
								   '+
								   @NotMatchedBySourceBK
								   +'
		THEN
			UPDATE SET
			Target.DeletedFlag = 1,
			Target.LastUpdateTime = GETDATE()
			;
')

						
					WHEN @ETLType LIKE 'InferredMemberLoad' THEN						 
('
		SELECT DISTINCT 
			' + @InfSourceBK + ' 
			,ExtractJobID
		INTO #Ext' + @ETLEntity + '
		FROM ext_' + @SourceLayerID + '.' + @SourceEntity + ' ext (NOLOCK)
			WHERE 
				ExtractJobID = @ExtractJobID 
				AND NOT EXISTS 
				(
					SELECT TOP 1 1 FROM ' + @DestTable + ' (NOLOCK) dest
					WHERE ext.' + @InfSourceBK + ' = dest.' + @InfDestBK + '
				)
				AND COALESCE(' + @InfSourceBK + ', '''') <> ''''


		/* insert the new rows from temporary table into the dw table */
		INSERT INTO ' + @DestTable + ' (
			' + @InfDestBK + ' 
			,SourceIdentifier
			,ExtractJobID
			,DeliveryJobID
			,LastUpdateTime
		)
		SELECT  Ext.' + @InfSourceBK + '
			,''' + @SourceLayerID + '_' + @SourceEntity + ''' AS SourceIdentifier 
			,Ext.ExtractJobID
			,@DeliveryJobID
			,GETDATE()
		FROM #Ext' + @ETLEntity + ' Ext

')
					WHEN @ETLType LIKE 'SnowFlakeMemberLoad' THEN
('
		/*select the rows for update to PRICE_PLAN_DIM snowflake table*/
			/* select the rows based on ExtractJobID into temporary table */

			SELECT DISTINCT 
				' + @InfSourceBK + ' 
				,ExtractJobID
			INTO #Ext' + @ETLEntity + '
			FROM ' + @SourceTable + ' (NOLOCK) dim
			WHERE 
				dim.ExtractJobID = @ExtractJobID
				AND NOT EXISTS 
					(
						SELECT TOP 1 1 FROM ' + @DestTable + ' (NOLOCK) dest
						WHERE dim.' + @InfSourceBK + ' = dest.' + @InfDestBK + '
					)
				AND COALESCE(' + @InfSourceBK + ', '''') <> ''''


			/* insert the new rows from temporary table into the dw table */
			INSERT INTO ' + @DestTable + ' (
				' + @InfDestBK + ' 
				,SourceIdentifier
				,ExtractJobID
				,DeliveryJobID
				,LastUpdateTime
			)
			SELECT  
				Ext.' + @InfSourceBK + '
				,''' + @SourceLayerID + '_' + @SourceEntity + ''' AS SourceIdentifier 
				,Ext.ExtractJobID
				,@DeliveryJobID
				,GETDATE()
			FROM #Ext' + @ETLEntity + ' Ext

			UPDATE ' + @SourceTable + '
				SET ' + @InfSourceSK + ' = DestDim.' + @InfDestSK + ',
					LastUpdateTime = GETDATE()				
			FROM 
				' + @SourceTable + ' SourceDim
				INNER JOIN ' + @DestTable + ' DestDim ON COALESCE(SourceDim.' + @InfSourceBK + ', ''Unknown'') = DestDim.' + @InfDestBK + '		
			WHERE  (SourceDim.' + @InfSourceSK + ' IS NULL)
				OR (SourceDim.' + @InfSourceSK + ' <> DestDim.' + @InfDestSK + ')


')



					WHEN @ETLType IN ('FACT-SNAPSHOT', 'FACT-TRANSACTION', 'FACT-SNAPSHOTHIST', 'FACT-ACCUMULATING', 'DIM-SCD2-BRIDGE', 'DIM-SCD1-BRIDGE') THEN 
('

		/* based on new value provided in the current extract based on the business key */
		SELECT 
			' + @SourceColumnList1 + 
				----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'LastChangeTime,' 
				    ELSE ''
				END) 
				+ 
			----------------
			'
			ExtractJobID,
			SourceIdentifier
		INTO #Err' + @ETLEntity + '
		FROM err_' + @SourceLayerID + '.' + @SourceEntity + ' (NOLOCK) Err
		WHERE NOT EXISTS (
			SELECT TOP 1 1 FROM ext_' + @SourceLayerID + '.' + @SourceEntity + ' Ext (NOLOCK)
			WHERE 
				' + @SourceErrToExtBK + 
				'AND Ext.ExtractJobID = @ExtractJobID
		)

		/* select the rows based on ExtractJobID into temporary table */

		
		SELECT 	

			' + @SourceColumnList1 + 
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'LastChangeTime,' 
				    ELSE ''
				END) 
				+ 
			----------------
			'
			ExtractJobID,
			SourceIdentifier
		INTO #Ext' + @ETLEntity + '
		FROM ext_' + @SourceLayerID + '.' + @SourceEntity + ' (NOLOCK)
		WHERE 
			ExtractJobID = @ExtractJobID 
		UNION ALL 
		SELECT 	
			' + @SourceColumnList1 + 	
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'LastChangeTime,' 
				    ELSE ''
				END) 
				+ 
			----------------
			'
			ExtractJobID,
			SourceIdentifier
		FROM #Err' + @ETLEntity +
'
'+
		(CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
'      
		DECLARE @SourceHitDeleteOffsetXML_temp XML
		DECLARE @SourceHitDeleteOffset TABLE
		(
			ExtractControlID NVARCHAR(40),
			LastExtractStartTime DATETIME,
			LastExtractEndTime DATETIME
		)

		IF object_Id(''tempdb..#ExtSourceIdentifier'') IS NOT NULL
		DROP TABLE #ExtSourceIdentifier

	    -- Get SourceIdentifier from source, used for delete process checking
		
		SELECT distinct SourceIdentifier
		INTO #ExtSourceIdentifier
		FROM #Ext' + @ETLEntity + ' 
	   	WHERE ExtractJobID = @ExtractJobID 
		
		-- Get list extract control hit delete process

        SET @SourceHitDeleteOffsetXML_temp = CONVERT(XML, ISNULL(@SourceHitDeleteOffsetXML,''''))
		
		INSERT INTO @SourceHitDeleteOffset
		(
			ExtractControlID,
			LastExtractStartTime,
			LastExtractEndTime
		)
		SELECT sHit.ExtractControlID,
		       sHit.LastExtractStartTime,
			   sHit.LastExtractEndTime
		FROM
			(
				SELECT 
					   Tbl.Col.value(''@ExtractControlID'', ''NVARCHAR(40)'') as ExtractControlID,  
					   Tbl.Col.value(''@LastExtractStartTime'', ''DATETIME'') as LastExtractStartTime,
					   Tbl.Col.value(''@LastExtractEndTime'', ''DATETIME'') as LastExtractEndTime
				FROM   @SourceHitDeleteOffsetXML_temp.nodes(''//ExtractControl'') Tbl(Col)
			) sHit
		INNER JOIN #ExtSourceIdentifier sIdentifier
		ON sHit.ExtractControlID = sIdentifier.SourceIdentifier

		' 
				    ELSE ''
				END) 
		+'

		/* use cte to set error message for missing value or unmatched lookup */
		/* use -1 for blank foreign key and -2 for unmatched foreign key */
		/* define here if there is any special cases for validation rules */
		;WITH cteLookup AS
		(
		SELECT 
			' + @SourceColumnList3 + 
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'ext.LastChangeTime,' 
				    ELSE ''
				END) 
				+ 
			----------------	
			'
			ext.ExtractJobID,
			ext.SourceIdentifier' + @ValidateSurrogateKeys + '
		FROM #Ext' + @ETLEntity + ' ext ' + @ForeignKeyTableJoin
		 + '
		) 
		SELECT 
			cteLookup.*,
			(' + 
						(CASE 
							WHEN (@ForeignKeyFieldList1 <> '') THEN
			'CASE 
				WHEN (' + @ForeignKeyFieldList1 + ')
					THEN ''NULL or Blank Business Key'' 
				WHEN (' + @ForeignKeyFieldList2 + ')
					THEN ''Invalid Business Key'' 
				ELSE NULL 
			END'
							ELSE	
					'NULL'
						END)
			 + ') AS ErrType, 
			(' + 
						(CASE 
							WHEN @ErrMessage <> '' THEN @ErrMessage 
							ELSE 'NULL' 
						END) + '
			) AS ErrMessage 
		INTO #Validated' + @ETLEntity + '  
		FROM cteLookup 

' +
--Add Loop to run through snapshots by the seperator column in the case of snapshot processing 
	   (CASE	 
		  WHEN @ETLType = 'FACT-SNAPSHOT' AND @SnapshotProcessSeperator <> '' THEN
'		SELECT DISTINCT ' + @SnapshotProcessSeperator + ' INTO #' + @SnapshotProcessSeperator + ' FROM #ValidatedWarehouseInventoryCurrent

		WHILE (SELECT COUNT(*) FROM #' + @SnapshotProcessSeperator + ') > 0 
		BEGIN

		  SELECT Top 1 @Current' + @SnapshotProcessSeperator + ' = ' + @SnapshotProcessSeperator + ' FROM #' + @SnapshotProcessSeperator
		  ELSE ''
	   END)
+ '
		  /* merge the records (insert new rows and update existing rows) */
		  ;MERGE ' + @DestTable + ' AS target
		  USING 
		  (
		  SELECT 
			' + @SourceColumnList4 + 
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
		   'LastChangeTime,
			ErrType,' 
				    ELSE ''
				END) 
				+ 
			----------------
'
			ExtractJobID,
			SourceIdentifier
		  FROM #Validated' + @ETLEntity 
		  + (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN '' 
				    ELSE 
		 '
		  WHERE ErrType IS NULL ' + (CASE  WHEN @SnapshotProcessSeperator <> '' THEN ' AND ' + @SnapshotProcessSeperator + ' = @Current' + @SnapshotProcessSeperator ELSE '' END)
				END) 
		  
		   +'
		  ) AS source 
		  (
			' + @DestColumnList1 + 
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
		  'LastChangeTime,
		   ErrType,' 
				    ELSE ''
				END) 
				+ 
			----------------
'
			ExtractJobID,
			SourceIdentifier
		  )
		  ON 
		  (' + @TargetToSourceBK +
			'
		  )
		  WHEN NOT MATCHED BY target '+
		   CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN ' AND source.ErrType IS NULL' 
				    ELSE ''
		   END
		  
		  +' THEN 
		  INSERT (
			' + @DestColumnList1 + 
			----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
		   'LastUpdateTime,
			SourceLastChangeTime,' 
				    ELSE ''
				END) 
				+ 
			----------------
			'
			ExtractJobID,
			DeliveryJobID,
			SourceIdentifier
		  )
		  VALUES (
			' + @DestColumnList2 + 
			----Update: Get LastChangeTime for fact
			(CASE
				WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
		   'GETDATE(),
			LastChangeTime,' 
			  ELSE ''
			 END) 
				+
			----------------
			'
			ExtractJobID,
			@DeliveryJobID,
			SourceIdentifier
	 )' 
		  +
			(CASE
				    WHEN @ETLType IN ('FACT-TRANSACTION', 'FACT-SNAPSHOTHIST') THEN '' 
				    ELSE  
					   (CASE
	   					  WHEN @SnapshotProcessSeperator <> '' THEN 
'
		  WHEN NOT MATCHED BY source AND Target.' + @SnapshotProcessSeperator + ' = @Current' + @SnapshotProcessSeperator + ' THEN
			DELETE'
						  ELSE ''
			 
			           END) + 


'
'+
		     CASE WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
'          -- Update DeletedFlag = 1 for rows in base layer which have source was deleted based on IsDeleteOffsetSchedule, ExtractStartTime, Business key and SourceIdentifier
            WHEN NOT MATCHED BY source 
							AND (@IsDeleteOffsetSchedule = 1)

							-- the target.SourceIdentifier exist in source which hit delete process
							AND Target.SourceIdentifier in (select SourceIdentifier = ExtractControlID from @SourceHitDeleteOffset)
							
							-- the target has SourceLastChangeTime fall in LastExtractStartTime and current date
							AND (Target.SourceLastChangeTime BETWEEN 
							                                 (Select LastExtractStartTime from @SourceHitDeleteOffset where ExtractControlID = Target.SourceIdentifier) 
														      AND 
															  (Select LastExtractEndTime from @SourceHitDeleteOffset where ExtractControlID = Target.SourceIdentifier) ) 
							
			THEN
			UPDATE SET		    
				Target.DeletedFlag = 1,
				Target.LastUpdateTime = GETDATE()
						'
			      ELSE ''
				  END
+'
		  WHEN MATCHED '+
		  CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN ' AND source.ErrType IS NULL' 
				    ELSE ''
		   END
		  
		  +' THEN
		  UPDATE SET 
		  --DestColumns minus BK fields
				' + @TargetToSourceExBK3 + 

				----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 
			   'LastUpdateTime = GETDATE(),
			    SourceLastChangeTime = source.LastChangeTime,
				DeletedFlag = 0,
				'
				    ELSE ''
				END) 
				+ 
		    	----------------
			   'ExtractJobID = source.ExtractJobID,
				DeliveryJobID = @DeliveryJobID,
				SourceIdentifier = source.SourceIdentifier' 
			   END) + '
		  ;
' +
--Add Loop to run through snapshots by the seperator column in the case of snapshot processing 
			 (CASE	 
				WHEN @ETLType = 'FACT-SNAPSHOT' AND @SnapshotProcessSeperator <> '' THEN
'
		  DELETE FROM #' + @SnapshotProcessSeperator + ' WHERE ' + @SnapshotProcessSeperator + ' = @Current' + @SnapshotProcessSeperator + '

		END 
'		  ELSE ''
	   END)
+ '
		/* truncate error table */
		TRUNCATE TABLE err_' + @SourceLayerID + '.' + @SourceEntity +
'

		/* load the error rows into error table */
		INSERT INTO err_' + @SourceLayerID + '.' + @SourceEntity + '
		(	
			' + @SourceColumnList1 +
			 
				----Update: Get LastChangeTime for fact
			   (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'LastChangeTime,' 
				    ELSE ''
				END) 
				+ 
		    	----------------
			'
			ExtractJobID,
			SourceIdentifier,
			ErrType,
			ErrMessage
		)
		SELECT 	
			' + @SourceColumnList1 + 
			 ----Update Get LastChangeTime for fact
				 (CASE
				    WHEN @ETLType IN ('FACT-ACCUMULATING') THEN 'LastChangeTime,' 
				    ELSE ''
				END) 
				+ 

				----------------  
			'
			ExtractJobID,
			SourceIdentifier,
			ErrType,
			ErrMessage
		FROM #Validated' + @ETLEntity + ' 
		WHERE ErrType IS NOT NULL
')
						
					ELSE ''						 
				END)									

			--Build Proc Footer
			SELECT @Sql_Proc_Footer = 
'

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
' + 
				(CASE 
					WHEN @ETLType IN ('FACT-SNAPSHOT', 'FACT-TRANSACTION', 'FACT-SNAPSHOTHIST', 'FACT-ACCUMULATING', 'DIM-SCD2-BRIDGE', 'DIM-SCD1-BRIDGE') THEN
'		IF OBJECT_ID(''tempdb..#Err' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Err' + @ETLEntity + '
		IF OBJECT_ID(''tempdb..#Validated' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Validated' + @ETLEntity
					ELSE
						''
				END) + 
'
		IF OBJECT_ID(''tempdb..#Ext' + @ETLEntity + ''') IS NOT NULL
			DROP TABLE #Ext' + @ETLEntity + '



END

GO

'

			--Add extended property to procedure
			SELECT @Sql_DW_ExtendedProps =
'
EXEC sys.sp_addextendedproperty 
	@name = N''MS_Description'', 
	@value = N''[CREATED FROM MetadataDB] SP delivering the data from table ' + 
				(CASE 
					WHEN @ETLType = 'SnowFlakeMemberLoad' THEN @SourceTable 
					ELSE 'Ext' + @SourceEntity 
				END) + ' to ' + @DestTable + ''', 
	@level0type = N''SCHEMA'', @level0name = ''dbo'', 
	@level1type = N''PROCEDURE'',  @level1name = ''' + @Sql_Proc_Name + ''';
GO

'		

			--Join together header, mapping and footer
			SELECT @Sql_Proc =  @Sql_Proc 
								+ @Sql_Proc_Header 
								+ @Sql_Proc_Middle 
								+ @Sql_Proc_Footer
								+ @Sql_DW_ExtendedProps


			--Delete processed row from tablelist
			DELETE FROM #ETL WHERE DestEntityID = @DestEntityID AND SourceEntityID = @SourceEntityID AND InfSourceBK = @InfSourceBK

			-------------------------------------------------------------------------------------------------------------------------------------
			select @Sql_Proc AS Sql_Proc,
				    @Sql_Proc_Header AS Sql_Proc_Header,
				    @Sql_Proc_Middle AS Sql_Proc_Middle,
				    @Sql_Proc_Footer AS Sql_Proc_Footer,
				    @Sql_DW_ExtendedProps AS Sql_DW_ExtendedProps,
				    @SourceColumnList1 AS SourceColumnList1,
				    @SourceColumnList2 AS SourceColumnList2
				    ,@SourceColumnList3 AS SourceColumnList3
				    ,@SourceColumnList4 AS  SourceColumnList4
				    ,@DestColumnList1 AS  DestColumnList1
				    ,@DestColumnList2 AS DestColumnList2
				    ,@SourceErrToExtBK AS  SourceErrToExtBK
				    ,@TargetToSourceBK AS  TargetToSourceBK
				    ,@TargetToSourceExBK AS TargetToSourceExBK
				    ,@TargetToSourceExBK2 AS TargetToSourceExBK2
				    ,@TargetToSourceExBK3 AS TargetToSourceExBK3
				    ,@HashSourceList AS HashSourceList
				    ,@HashTargetList AS HashTargetList
			-------------------------------------------------------------------------------------------------------------------------------------

			--reset variables
			SELECT @SourceColumnList1 = ''
			SELECT @SourceColumnList2 = ''
			SELECT @SourceColumnList3 = ''
			SELECT @SourceColumnList4 = ''
			SELECT @DestColumnList1 = ''
			SELECT @DestColumnList2 = ''
			SELECT @SourceErrToExtBK = ''
			SELECT @TargetToSourceBK = ''
			SELECT @TargetToSourceExBK = ''
			SELECT @TargetToSourceExBK2 = ''
			SELECT @TargetToSourceExBK3 = ''
			SELECT @HashSourceList = ''
			SELECT @HashTargetList = '' 
			SELECT @InvalidErrorCount = 0
			SELECT @MissingErrorCount = 0
			SELECT @ValidateSurrogateKeys = ''
			SELECT @ForeignKeyTableJoin = ''
			SELECT @ForeignKeyFieldList1 = ''
			SELECT @ForeignKeyFieldList2 = ''
			SELECT @ErrMessage = ''
			SELECT @Sql_Proc_Header = ''
			SELECT @Sql_Proc_Middle = ''
			SELECT @Sql_Proc_Footer = ''
			SELECT @Sql_DW_ExtendedProps = ''
		END
		
		SELECT @Sql_Proc = '
USE ' + @DWExtract_ModelDB + '
GO

-----------------------------------------
--Printing Delivery Stored Procedures
-----------------------------------------
'	+ COALESCE(@Sql_Proc,'')


		
		EXEC dbo.udpLongPrint @Sql_Proc


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
			@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')

		/* Building the message string that will contain original error information */
		SELECT  @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, '
		 + 'Message: ' + ERROR_MESSAGE()

		/* Raise an error: msg_str parameter of RAISERROR will contain the original error information */
		RAISERROR (@ErrorMessage, @ErrorSeverity, 1, @ErrorNumber,
			@ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine)
	END CATCH

	--Finally Section
	/* clean up the temporary table */













