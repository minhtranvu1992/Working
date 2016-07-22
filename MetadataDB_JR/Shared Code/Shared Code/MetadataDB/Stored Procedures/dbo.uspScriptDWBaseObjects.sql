







-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the DW Tables
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWBaseObjects] 
(
	@Environment AS VARCHAR(100) = 'Model',
	@DWData_ModelDB AS VARCHAR(100) 
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @EnableForeignKeys AS VARCHAR(100)
		DECLARE @CompressionType AS VARCHAR(100)

		--Depending on the @environment variable retrieve the Database Names
		IF (@Environment = 'Model')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_Model') )
			SET @EnableForeignKeys = (SELECT dbo.fnGetParameterValue('EnableForeignKeys_Model') )	
		END
		ELSE IF (@Environment = 'DEV')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_DEV') )
			SET @EnableForeignKeys = (SELECT dbo.fnGetParameterValue('EnableForeignKeys_DEV') )	
		END
		ELSE IF (@Environment = 'UAT')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_UAT') )
			SET @EnableForeignKeys = (SELECT dbo.fnGetParameterValue('EnableForeignKeys_UAT') )	
		END
		ELSE IF (@Environment = 'PROD')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_PROD') )
			SET @EnableForeignKeys = (SELECT dbo.fnGetParameterValue('EnableForeignKeys_PROD') )	
		END

		--CREATE Scripting Variables
		DECLARE @Sql_DW_DropConstraints AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_CreateConstraints AS VARCHAR(MAX) = ''
		DECLARE @SQL_DW_FKIndexes AS VARCHAR(MAX) = ''	
		DECLARE @Sql_DW AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_Header AS VARCHAR(MAX)	 = ''
		DECLARE @Sql_DW_Mapping AS VARCHAR(MAX) = ''	
		DECLARE @Sql_DW_PrimaryKeyList AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_DimBusKeyList AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_Footer AS VARCHAR(MAX)	 = ''
		DECLARE @Sql_DW_ExtendedProps AS VARCHAR(MAX)  = ''
		DECLARE @Sql_DW_ColumnConstraint AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_FullTableName AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_PopulateDimInsertList AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_PopulateDim AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_ALL AS VARCHAR(MAX) = ''

		--Create DWLayer Variables
		DECLARE @Sql_DW_Schemas AS VARCHAR(MAX) = ''
		DECLARE @DWLayerAbbreviation AS VARCHAR(100)
		DECLARE @DWLayerID AS VARCHAR(40)

		--Create DWObject Level Variables
		DECLARE @CreateOrder AS INT
		DECLARE @CreateErrorTable AS INT
		DECLARE @DWObjectID AS VARCHAR(100)
		DECLARE @DWObjectTypeID AS VARCHAR(100)
		DECLARE @DWObjectLoadLogic AS VARCHAR(100)
		DECLARE @DWObjectTypeExt AS VARCHAR(100)
		DECLARE @DWObjectName AS VARCHAR(100)
		DECLARE @DWObjectDESC AS VARCHAR(100)

		--Create DWElement Level Variables
		DECLARE @DWElementName  AS VARCHAR(100)
		DECLARE @DataType  AS VARCHAR(40)
		DECLARE @PrimaryKeyOrder  AS INT
		DECLARE @ForeignKeyTable  AS VARCHAR(100)
		DECLARE @ForeignKeyTableKey AS VARCHAR(100)
		DECLARE @DWElementDesc  AS VARCHAR(4000)
		DECLARE @DimBusinessKeyOrder  AS INT
		DECLARE @ProvideDefault AS INT
		DECLARE @PrimaryKey AS VARCHAR(100)
		DECLARE @DefinedDefaultValue AS VARCHAR(MAX)

		--Recreate table to hold DW Table Metadata
		if object_id ('tempdb..#DWObjectList' ) is not null
		   DROP TABLE #DWObjectList

		CREATE TABLE #DWObjectList (
			CreateOrder INT NULL,
			CreateErrorTable INT NULL,
			DWObjectID varchar(100) NOT NULL,
			DWLayerAbbreviation varchar(40) NOT NULL,
			DWLayerID varchar(40) NOT NULL,
			DWObjectTypeID varchar(100) NOT NULL,
			DWObjectLoadLogic varchar(40) NOT NULL,
			DWObjectTypeExt varchar(4) NOT NULL,
			DWObjectName varchar(100) NOT NULL,
			DWObjectDesc varchar(4000) NULL,
			ForeignKeyTableKey varchar(100) NULL
		) 

		CREATE CLUSTERED INDEX IX_DWObjectList
		ON #DWObjectList 
		(
			CreateOrder ASC, DWObjectID ASC
		)

		--Recreate table to hold DW Element Metadata
		if object_id ('tempdb..#DWElements' ) is not null
		   DROP TABLE #DWElements

		CREATE TABLE #DWElements (
			RowID int,
			DWElementName varchar(100),
			DataType varchar(40),
			PrimaryKeyOrder int,
			DimBusinessKeyOrder int,
			ForeignKeyTable varchar(100),
			ForeignKeyTableKey varchar(100),
			DWElementDesc varchar(4000),
			ProvideDefault int,
			DefinedDefaultValue varchar(max)
		) 

		CREATE CLUSTERED INDEX IX_DWElements
		ON #DWElements 
		(
			RowID ASC
		)

		--Build list of Base Level Data Warehouse Objects
		--First add those objects that will not need to contain lookups to other tables
		INSERT INTO #DWObjectList
		SELECT
			1 AS CreateOrder,		--to be populated in upcoming update statements
			1 AS CreateErrorTable,	--to be populated in upcoming update statements
			DWObject.DWObjectID,
			DWLayer.DWLayerAbbreviation,
			DWObject.DWLayerID,
			DWObjectType.DWObjectTypeID,
			DWObjectType.DWObjectLoadLogic,
			CASE 
				WHEN DWObjectType.DWObjectGroup LIKE '%Dim%' THEN 'Dim'
				WHEN DWObjectType.DWObjectGroup LIKE '%Fact%' THEN 'Fact'
				ELSE 'Unk'
			END AS DWObjectTypeExt, 
			DWObject.DWObjectName,
			DWObject.DWObjectDesc,
			(CASE 
				WHEN DWElementName LIKE '%ID' THEN REPLACE(DWElementName,'ID','SK') 
				WHEN DWElementName NOT LIKE '%ID'  THEN DWElementName + 'SK' 
				ELSE DWElementName
			END) AS ForeignKeyTableKey
		FROM
			dbo.DWObject DWObject
			INNER JOIN dbo.DWLayer DWLayer
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWObjectType DWObjectType
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			LEFT JOIN dbo.DWElement DWElement
				ON DWObject.DWObjectID = DWElement.DWObjectID
				AND DWObjectType.DWObjectTypeID IN ('DIM-SCD1', 'DIM-SCD2', 'DIM-STATIC')
				AND DWElement.BusinessKeyOrder = 1
		WHERE 
			DWLayer.DWLayerType = 'BASE' AND DWObject.IncludeInBuild = 1

		--Using this as a base and working backwards to the fact tables through the layers of snowflaking, add metadata for the other layers of 
		--Tables.

		UPDATE #DWObjectList
			SET CreateOrder = t.CreateOrder,
			CreateErrorTable = t.CreateErrorTable
		FROM
		#DWObjectList DWObjectList 
		INNER JOIN 
		(
			SELECT 
				DWElement.DWObjectID,
				1 AS CreateOrder,
				0 AS CreateErrorTable
			FROM 
				#DWObjectList  DWObjectList 
				INNER JOIN dbo.DWElement DWElement
					ON DWObjectList.DWObjectID = DWElement.DWObjectID
			GROUP BY DWElement.DWObjectID
			HAVING COUNT(DISTINCT [EntityLookupObjectID]) = 0
		) t
		ON t.DWObjectID = DWObjectList.DWObjectID

		--Get Distinct of Schemas 
		if object_id ('tempdb..#DWSchemaList_temp' ) is not null
		   DROP TABLE #DWSchemaList_temp

		SELECT DISTINCT DWLayerAbbreviation
			INTO #DWSchemaList_temp
		FROM
			#DWObjectList

		--Build Schema Script
		WHILE (SELECT COUNT(*) FROM #DWSchemaList_temp) > 0
			BEGIN
				SELECT TOP 1 
					@DWLayerAbbreviation = DWLayerAbbreviation
				FROM #DWSchemaList_temp 

				SELECT @Sql_DW_Schemas = @Sql_DW_Schemas + '
PRINT N''Creating Schema ' + @DWLayerAbbreviation + '...''
GO

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @DWLayerAbbreviation + ''')
	execute(''CREATE SCHEMA ' + @DWLayerAbbreviation + ' AUTHORIZATION dbo'')
GO

'
				--Delete processed row from tablelist
				DELETE FROM #DWSchemaList_temp WHERE DWLayerAbbreviation = @DWLayerAbbreviation
			END

		if object_id ('tempdb..#DWObjectList_temp' ) is not null
		   DROP TABLE #DWObjectList_temp

		SELECT *
			INTO #DWObjectList_temp
		FROM
			#DWObjectList


		--Loop through metadta table list in order
		WHILE (SELECT COUNT(*) FROM #DWObjectList_temp) > 0
			BEGIN
				SELECT TOP 1 
					@CreateOrder = CreateOrder,
					@CreateErrorTable = CreateErrorTable,
					@DWObjectID = DWObjectID,
					@DWLayerAbbreviation = DWLayerAbbreviation,
					@DWLayerID = DWLayerID,
					@DWObjectTypeID = DWObjectTypeID,
					@DWObjectLoadLogic = DWObjectLoadLogic,
					@DWObjectTypeExt = DWObjectTypeExt,
					@DWObjectName = DWObjectName,
					@DWObjectDESC = REPLACE(COALESCE(DWObjectDesc, ''), '''', ''''''), 
					@PrimaryKey = ForeignKeyTableKey
				FROM #DWObjectList_temp
		
			
				--Set Full Table Name
				SELECT @Sql_DW_FullTableName = @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName

				--Load Extract Layer element metadata into temp table
				INSERT INTO #DWElements
				SELECT 
					Row_Number() OVER (ORDER BY COALESCE(PrimaryKeyOrder, 999), COALESCE(DimBusinessKeyOrder, 999), DWElementName) AS RowID,	
					DWElementName, DataType, PrimaryKeyOrder, DimBusinessKeyOrder, ForeignKeyTable, ForeignKeyTableKey, DWElementDesc, ProvideDefault, DefinedDefaultValue
				FROM
					--Get information for DWElement, including converting IDs to surrogate keys
					(SELECT 
							(CASE 
								WHEN (EntityLookupObjectID IS NOT NULL AND [DataType] LIKE '%Date%')  
									THEN REPLACE(DWElementName,'Date','DateID') 
								WHEN (EntityLookupObjectID IS NOT NULL AND DWElementName LIKE '%ID')  OR (@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1 AND DWElementName LIKE '%ID' AND DWElementName <> 'DateID')
									THEN REPLACE(DWElementName,'ID','SK') 
								WHEN (EntityLookupObjectID IS NOT NULL AND DWElementName NOT LIKE '%ID')  OR (@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1 AND DWElementName NOT LIKE '%ID')
									THEN DWElementName + 'SK' 
								ELSE DWElementName
							END) AS DWElementName, 
							(CASE 
								WHEN (EntityLookupObjectID IS NOT NULL)  OR (@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1)
									THEN 'integer' 
								ELSE [DataType]
							END) AS [DataType]
							,(CASE 
								WHEN BusinessKeyOrder IS NOT NULL AND ((EntityLookupObjectID IS NOT NULL AND DWElementName LIKE '%ID') OR (@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1))
									THEN BusinessKeyOrder
								ELSE BusinessKeyOrder
							END) AS PrimaryKeyOrder
							,NULL AS DimBusinessKeyOrder
							,(CASE 
								WHEN (EntityLookupObjectID IS NOT NULL AND @DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1) 
									THEN NULL
								ELSE DWObjectList.DWLayerAbbreviation + '.' + DWObjectList.DWObjectTypeExt + DWObjectList.DWObjectName
							END) AS ForeignKeyTable
							,(CASE 
								WHEN (EntityLookupObjectID IS NOT NULL AND @DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1)  
									THEN NULL 
								WHEN (EntityLookupObjectID IS NOT NULL)   
									THEN DWObjectList.ForeignKeyTableKey 
								ELSE NULL 
							END) AS ForeignKeyTableKey
							,DWElementDesc
							,(CASE 
								WHEN (EntityLookupObjectID IS NOT NULL AND @DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1)  
									THEN 0 
								WHEN (EntityLookupObjectID IS NOT NULL AND DWElement.DWElementName NOT LIKE '%Date%')   
									THEN 1 
								ELSE 0 
							END) AS ProvideDefault,
							(CASE 
								WHEN EntityLookupObjectID IS NULL AND BusinessKeyOrder Is NULL THEN
								    (CASE 
									   WHEN DWElement.DefaultTypeID = 'DomainDefault' THEN DomainDataType.DomainDefaultValue
									   WHEN DWElement.DefaultTypeID = 'UserDefined' THEN DWElement.BespokeDefaultLogic
								    END)
								ELSE NULL
							 END) AS DefinedDefaultValue
						FROM dbo.DWElement DWElement
							LEFT JOIN  #DWObjectList DWObjectList ON DWElement.EntityLookupObjectID = DWObjectList.DWObjectID
							LEFT JOIN dbo.DomainDataType DomainDataType ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
						WHERE 
							DWElement.DWObjectID = @DWObjectID
						UNION ALL
						--When the field has been converted to a surrogate key we need to add back in the original for all dimentions businesskeys 
						--and for all foreign business keys in a fact or dimension where the RetainBusinessKey flag has been ticked
						SELECT 
							DWElementName, 
							DataType, 
							NULL AS PrimaryKeyOrder,
							(CASE 
								WHEN 
									(@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1)
									THEN BusinessKeyOrder
								ELSE NULL
							END) AS DimBusinessKeyOrder, 
							NULL AS ForeignKeyTable,
							NULL AS ForeignKeyTableKey,
							DWElementDesc,
							0 AS ProvideDefault,
							(CASE 
								WHEN EntityLookupObjectID IS NOT NULL AND RetainBusinessKey = 1 THEN
								    (CASE 
									   WHEN DWElement2.DefaultTypeID = 'DomainDefault' THEN DomainDataType2.DomainDefaultValue
									   WHEN DWElement2.DefaultTypeID = 'UserDefined' THEN DWElement2.BespokeDefaultLogic
								    END)
								ELSE NULL
							 END) AS 	DefinedDefaultValue							
						FROM dbo.DWElement DWElement2
  							LEFT JOIN dbo.DomainDataType DomainDataType2 ON DWElement2.DomainDataTypeID = DomainDataType2.DomainDataTypeID
						WHERE 
							DWElement2.DWObjectID = @DWObjectID AND 
							(
								(EntityLookupObjectID IS NOT NULL AND RetainBusinessKey = 1) OR
								(@DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1)
							)
						UNION ALL
						--Get metadata for those data elements
						--When the primary business key is being used to snowflake to another table with the same business key 
						SELECT 
							(CASE 
								WHEN (DWElementName LIKE '%ID')  
									THEN DWObjectList3.DWLayerID + REPLACE(DWElementName,'ID','SK') 
								WHEN (DWElementName NOT LIKE '%ID') 
									THEN DWObjectList3.DWLayerID + DWElementName + 'SK' 
								ELSE NULL
							END) AS DWElementName, 
							'Integer' AS DataType, 
							NULL AS PrimaryKeyOrder,
							NULL AS DimBusinessKeyOrder, 
							DWObjectList3.DWLayerAbbreviation + '.' + DWObjectList3.DWObjectTypeExt + DWObjectList3.DWObjectName AS ForeignKeyTable,
							DWObjectList3.ForeignKeyTableKey,
							DWElementDesc,
							1 AS ProvideDefault,
							NULL AS DefinedDefaultValue								
						FROM dbo.DWElement DWElement3
  							LEFT JOIN dbo.DomainDataType DomainDataType3 ON DWElement3.DomainDataTypeID = DomainDataType3.DomainDataTypeID
							LEFT JOIN  #DWObjectList DWObjectList3 ON DWElement3.EntityLookupObjectID = DWObjectList3.DWObjectID
						WHERE 
							DWElement3.DWObjectID = @DWObjectID AND 
							(
								(EntityLookupObjectID IS NOT NULL AND @DWObjectTypeExt = 'Dim' AND BusinessKeyOrder = 1) 
							)
					) t	

				--Add MS_Description extended property for DWObject
				SELECT @Sql_DW_ExtendedProps = 
'

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWObjectDESC + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''';
		GO
'
				--Loop through the DWElements and build the table create string
				WHILE (SELECT COUNT(*) FROM #DWElements) > 0
				BEGIN
					SELECT TOP 1 
						@DWElementName = COALESCE(DWElementName,''),
						@DataType = COALESCE(DataType,''),
						@PrimaryKeyOrder = COALESCE(PrimaryKeyOrder, 999), 
						@DimBusinessKeyOrder = COALESCE(DimBusinessKeyOrder, 999), 
						@ForeignKeyTable = COALESCE(ForeignKeyTable,''),
						@ForeignKeyTableKey = COALESCE(ForeignKeyTableKey,''),
						@DWElementDesc = REPLACE(COALESCE(DWElementDesc, ''), '''', ''''''), 
						@ProvideDefault = ProvideDefault,
						@DefinedDefaultValue = DefinedDefaultValue
					FROM #DWElements 		

					SELECT @Sql_DW_Mapping =  
						@Sql_DW_Mapping + '
			'			+ @DWElementName + ' ' 
						+ @DataType 
						+ (CASE 
							WHEN (@PrimaryKeyOrder <> 999 OR @DimBusinessKeyOrder <> 999 OR (@ForeignKeyTable <> '' AND @DWElementName NOT LIKE '%DateID' )) 
								THEN ' NOT NULL' 
								ELSE ' NULL' 
							END)  
						+ (CASE 
							WHEN (@PrimaryKeyOrder = 1 AND @DWObjectTypeExt = 'Dim' AND @DWElementName <> 'DateID') 
								THEN ' IDENTITY(1, 1)' 
								ELSE '' 
							END) 
						+ (CASE 
								--Defaults for 
								WHEN  @ProvideDefault = 1 THEN 
									CASE 
										WHEN @DataType LIKE '%char%' THEN ' CONSTRAINT [DF_' + @DWLayerAbbreviation + '_' + @DWObjectName + '_' + @DWElementName + '] DEFAULT (''Unknown'')'
										WHEN @DataType LIKE '%date%' THEN ' CONSTRAINT [DF_' + @DWLayerAbbreviation + '_' + @DWObjectName + '_' + @DWElementName + '] DEFAULT (''1900-01-01 00:00:00'')'
										WHEN @DataType LIKE '%int%'  THEN ' CONSTRAINT [DF_' + @DWLayerAbbreviation + '_' + @DWObjectName + '_' + @DWElementName + '] DEFAULT (-1)'
										ELSE '' 
									END
								WHEN @ProvideDefault = 0 AND @DefinedDefaultValue IS NOT NULL THEN 
								    ' CONSTRAINT [DF_' + @DWLayerAbbreviation + '_' + @DWObjectName + '_' + @DWElementName + '] DEFAULT ' + @DefinedDefaultValue

								ELSE ''
							END) + ','
				
					--Build Primary Key List
						IF (@PrimaryKeyOrder  = 1)
							BEGIN
								SELECT @Sql_DW_PrimaryKeyList = @DWElementName + ' ASC'	
								SELECT @Sql_DW_PopulateDimInsertList = @DWElementName + ','
							END
						ELSE IF (@PrimaryKeyOrder  < 999)
							BEGIN
								SELECT @Sql_DW_PrimaryKeyList = @Sql_DW_PrimaryKeyList + '
				,'					+ @DWElementName + ' ASC'		
							END	

					--Build Dimension Business Key List
						IF (@DimBusinessKeyOrder  = 1)
							BEGIN
								SELECT @Sql_DW_DimBusKeyList = @DWElementName + ' ASC'		
								SELECT @Sql_DW_PopulateDimInsertList = @Sql_DW_PopulateDimInsertList + @DWElementName
							END
						ELSE IF (@DimBusinessKeyOrder  < 999)
							BEGIN
								SELECT @Sql_DW_DimBusKeyList = @Sql_DW_DimBusKeyList + '
			,'						+ @DWElementName + ' ASC'		
							END	

					SELECT @Sql_DW_ColumnConstraint = @DWObjectTypeExt + @DWObjectName + '_' + REPLACE(@DWElementName, 'SK', '')
					--Build Drop Foreign Key List and Create Foreign Key List
					IF (@ForeignKeyTable <> '' AND @DWElementName NOT LIKE '%DateID%') 
						BEGIN
							SELECT @Sql_DW_DropConstraints = @Sql_DW_DropConstraints + '
     PRINT N''Altering Table ' + @Sql_DW_FullTableName + ' Dropping Constraint FK_' + @Sql_DW_ColumnConstraint + '...''
     GO

	IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N''' + @DWLayerAbbreviation + '.FK_' + @Sql_DW_ColumnConstraint + ''') AND parent_object_id = OBJECT_ID(N''' + @Sql_DW_FullTableName + '''))
		ALTER TABLE ' + @Sql_DW_FullTableName + ' DROP CONSTRAINT FK_' + @Sql_DW_ColumnConstraint + '
	GO
	'
							SELECT @Sql_DW_CreateConstraints = @Sql_DW_CreateConstraints + '
     PRINT N''Altering Table ' + @Sql_DW_FullTableName + ' Adding Constraint FK_' + @Sql_DW_ColumnConstraint + '...''
     GO

	ALTER TABLE ' + @Sql_DW_FullTableName + '  WITH CHECK ADD  CONSTRAINT FK_' + @Sql_DW_ColumnConstraint + ' FOREIGN KEY(' + @DWElementName + ')
	REFERENCES ' + @ForeignKeyTable + ' (' + @ForeignKeyTableKey + ')
	GO

	ALTER TABLE ' + @Sql_DW_FullTableName + ' CHECK CONSTRAINT FK_' + @Sql_DW_ColumnConstraint + '
	GO
	'							
	
							SELECT @SQL_DW_FKIndexes = @SQL_DW_FKIndexes + '
		PRINT N''Creating NonClustered Index IX_' + @Sql_DW_ColumnConstraint + ' ON ' + @Sql_DW_FullTableName + '...''
		GO

		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @DWLayerAbbreviation + '.IX_' + @Sql_DW_ColumnConstraint + '''))
			CREATE NONCLUSTERED INDEX IX_' + @Sql_DW_ColumnConstraint + ' ON ' + @Sql_DW_FullTableName +  '
			(
				' + @DWElementName + ' ASC
			)  WITH (DATA_COMPRESSION = ' + @CompressionType + ')  
		GO
'
						END

					DELETE FROM #DWElements WHERE DWElementName = @DWElementName

					--Add DWElement Level MS_Description Extended Property
					SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWElementDesc + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''' + @DWElementName + ''';		
		GO
'

				END	

				IF ( @DWObjectTypeID IN ('DIM-SCD1', 'DIM-SCD2') )
				BEGIN
					SELECT @Sql_DW_PopulateDim = @Sql_DW_PopulateDim + '
PRINT N''Inserting Special Records into Dimension ' + @Sql_DW_FullTableName + '...''
GO

SET IDENTITY_INSERT ' + @Sql_DW_FullTableName + ' ON
INSERT INTO ' + @Sql_DW_FullTableName + ' (' + @Sql_DW_PopulateDimInsertList + ', LastUpdateTime, DeliveryJobID, ExtractJobID, SourceIdentifier)
SELECT special_records.SK, special_records.BK, special_records.LastUpdateTime, special_records.DeliveryJobID, special_records.ExtractJobID, special_records.SourceIdentifier
FROM
	(SELECT -1 AS SK, ''Unknown'' AS BK, GETDATE() AS LastUpdateTime,-1 AS DeliveryJobID, -1 AS ExtractJobID, ''Metadata'' AS SourceIdentifier
	UNION
	SELECT -2 AS SK, ''Invalid'' AS BK, GETDATE() AS LastUpdateTime,-2 AS DeliveryJobID, -2 AS ExtractJobID, ''Metadata'' AS SourceIdentifier) special_records
	LEFT JOIN ' + @Sql_DW_FullTableName + ' dim
	ON special_records.SK = dim.' + @PrimaryKey + ' 
WHERE 
	dim.' + @PrimaryKey + ' IS NULL
SET IDENTITY_INSERT ' + @Sql_DW_FullTableName + ' OFF

'
				END

				--Add MS_Description Extended Properties for standard DW Table Columns
				SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] This is the LoadTime for the record'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''LoadTime'';		
		GO
'
				IF (@DWObjectLoadLogic IN ('Upsert', 'Historical') ) 
					SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] This is the Last time the record was updated in this table. Not related to the Source Change Time'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''LastUpdateTime'';		
		GO
'
			
				IF (@DWObjectLoadLogic <> ('None') ) 
					SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Job identifier for the ETL Extract from the source'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''ExtractJobID'';		
		GO

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Job identifier for the ETL Delivery to the table'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''DeliveryJobID'';		
		GO

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] This identifies which sourcefeed the record was created or last updated from'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''SourceIdentifier'';		
		GO
'

				IF (@DWObjectLoadLogic = ('Historical') )
					SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Time from which ' + @Sql_DW_FullTableName + ' record is valid'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''ValidFromTime'';		
		GO

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Time to which ' + @Sql_DW_FullTableName + ' record is valid'',
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''ValidToTime'';		
		GO

'			
		
				--Build DW Table
				SELECT @Sql_DW_Header = '

PRINT N''Dropping Table ' + @Sql_DW_FullTableName + '...''
GO

	------------------------------------------------------------------
	-- Printing Table ' + @Sql_DW_FullTableName + '
	------------------------------------------------------------------
				
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Sql_DW_FullTableName + ''') AND type in (N''U''))
		DROP TABLE ' + @Sql_DW_FullTableName + '
		GO

PRINT N''Creating Table ' + @Sql_DW_FullTableName + '...''
GO

		SET ANSI_NULLS ON
		GO

		SET QUOTED_IDENTIFIER ON
		GO


		CREATE TABLE ' + @Sql_DW_FullTableName + ' ('


				SELECT @Sql_DW_Footer = '	
			LoadTime smalldatetime NOT NULL,
'  +				(CASE
						WHEN (@DWObjectLoadLogic IN ('Upsert', 'Historical') ) THEN
'			LastUpdateTime smalldatetime NOT NULL,
'
						ELSE ''
					END) +
					(CASE
						WHEN (@DWObjectLoadLogic <> 'None' ) THEN
'			DeliveryJobID int NOT NULL,
			ExtractJobID int NOT NULL,
			SourceIdentifier varchar(40) NULL,
'					
						ELSE ''
					END) +
					(CASE
						WHEN (@DWObjectLoadLogic = 'Historical' ) THEN 
'			ValidFromTime DateTime NOT NULL,
			ValidToTime DateTime NULL,
'
						ELSE ''
					END) +
'			CONSTRAINT PK_' + @DWObjectTypeExt + @DWObjectName + ' PRIMARY KEY CLUSTERED 
			(
				' +
					(CASE
						WHEN (@DWObjectLoadLogic = 'Historical' ) THEN 
							@Sql_DW_PrimaryKeyList + ',
				ValidFromTime ASC'
						ELSE @Sql_DW_PrimaryKeyList
					END) + '
			)
		) WITH (DATA_COMPRESSION = ' + @CompressionType + ')
		GO

PRINT N''Altering Table ' + @Sql_DW_FullTableName + ' Adding Constraint DF_' + @DWObjectTypeExt + @DWObjectName + '_LoadTime...''
GO

		ALTER TABLE ' + @Sql_DW_FullTableName + ' ADD  CONSTRAINT DF_' + @DWObjectTypeExt + @DWObjectName + '_LoadTime  DEFAULT (getdate()) FOR LoadTime
		GO

' +					(CASE 
						WHEN @DWObjectTypeExt = 'Dim' AND @DWObjectName <> 'Date' THEN
'
PRINT N''Creating Unique NonClustered Index IX_' + @DWObjectTypeExt + @DWObjectName + '_BKLookup...''
GO

		CREATE UNIQUE NONCLUSTERED INDEX IX_' + @DWObjectTypeExt + @DWObjectName + '_BKLookup ON ' + @Sql_DW_FullTableName + ' 
		(
			' + @Sql_DW_DimBusKeyList + 
						(CASE 
							WHEN @DWObjectLoadLogic = 'Historical' THEN ',
			ValidFromTime ASC'
							ELSE ''
						END) + '			
		)  WITH (DATA_COMPRESSION = ' + @CompressionType + ') ' 
						ELSE ''
					END)


				--Join together header, mapping and footer
				SELECT @Sql_DW = @Sql_DW + @Sql_DW_Header + @Sql_DW_Mapping + @Sql_DW_Footer + @SQL_DW_FKIndexes + @Sql_DW_ExtendedProps

				--Delete processed row from tablelist
				DELETE FROM #DWObjectList_temp WHERE DWObjectID = @DWObjectID

				--reset variables
				SELECT @SQL_DW_FKIndexes = ''
				SELECT @Sql_DW_Header = ''
				SELECT @Sql_DW_Mapping = ''
				SELECT @Sql_DW_Footer = ''
				SELECT @Sql_DW_PrimaryKeyList = ''
				SELECT @Sql_DW_DimBusKeyList = ''
				SELECT @Sql_DW_ExtendedProps = ''	

			END


		SELECT @Sql_DW_ALL = '
USE ' + @DWData_ModelDB + '
GO

-----------------------------------------
--Printing Schemas
-----------------------------------------
'	+ COALESCE(@Sql_DW_Schemas,'') + '
-----------------------------------------
--Printing Drop Constraints
-----------------------------------------
'	+ COALESCE(@Sql_DW_DropConstraints,'') + '
-----------------------------------------
--Printing DW Tables
-----------------------------------------
'	+ COALESCE(@Sql_DW,'') + '
-----------------------------------------
--Printing Dimension Special Members
-----------------------------------------
'	+ COALESCE(@Sql_DW_PopulateDim,'') + '
-----------------------------------------
--Printing Create Constraints
-----------------------------------------
'	+ COALESCE(@Sql_DW_CreateConstraints,'')  


		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Base_Objects'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT 1, 'DW_Base_Objects', @Sql_DW_ALL
		END
		
		EXEC dbo.udpLongPrint @Sql_DW_ALL
		
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

END