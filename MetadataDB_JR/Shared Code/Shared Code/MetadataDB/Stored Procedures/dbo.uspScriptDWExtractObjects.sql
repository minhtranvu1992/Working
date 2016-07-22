





-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWExtractObjects]
(
	@Environment AS VARCHAR(100) = 'Model',
	@DWExtract_ModelDB AS VARCHAR(100),
	@DWData_TargetDB AS VARCHAR(100)
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @CompressionType AS VARCHAR(100)

		--Depending on the @environment variable retrieve the Database Names
		IF (@Environment = 'Model')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_Model') )
		END
		ELSE IF (@Environment = 'DEV')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_DEV') )
		END
		ELSE IF (@Environment = 'UAT')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_UAT') )
		END
		ELSE IF (@Environment = 'PROD')
		BEGIN
			SET @CompressionType = (SELECT dbo.fnGetParameterValue('CompressionType_PROD') )
		END


		DECLARE @Sql_Extract_ALL AS VARCHAR(MAX) = ''
		DECLARE @Sql_Extract AS VARCHAR(MAX) = ''
		DECLARE @Sql_Extract_Header AS VARCHAR(MAX)	 = ''
		DECLARE @Sql_Extract_Mapping AS VARCHAR(MAX) = ''	
		DECLARE @Sql_Extract_BK AS VARCHAR(MAX) = ''
		DECLARE @Sql_Extract_Footer AS VARCHAR(MAX)	 = ''

		DECLARE @Sql_Error AS VARCHAR(MAX) = ''
		DECLARE @Sql_Error_Header AS VARCHAR(MAX) = ''	
		DECLARE @Sql_Error_Footer AS VARCHAR(MAX) = ''		

		DECLARE @Sql_Synonym AS VARCHAR(MAX) = ''
		DECLARE @Sql_DW_ExtendedProps AS VARCHAR(MAX)  = ''
		DECLARE @Sql_DW_Schemas AS VARCHAR(MAX)  = ''

		--Create DWLayer Variables
		DECLARE @DWLayerAbbreviation AS VARCHAR(100)
		DECLARE @DWLayerID AS VARCHAR(40)

		--Create variable for looping through layers of Snowflaking
		DECLARE @CreateOrderLvl AS INT = 0

		DECLARE @CreateErrorTable AS INT
		DECLARE @DWObjectID AS VARCHAR(100)
		DECLARE @DWObjectType AS VARCHAR(100)
		DECLARE @DWObjectLoadLogic AS VARCHAR(100)
		DECLARE @DWObjectTypeExt AS VARCHAR(100)
		DECLARE @DWObjectName AS VARCHAR(100)
		DECLARE @DWObjectDESC AS VARCHAR(4000)
		DECLARE @SchemaName AS VARCHAR(40)
		DECLARE @SynonymOnly AS INT
		DECLARE @FullExtractTableName AS VARCHAR(100)
		DECLARE @FullErrorTableName AS VARCHAR(100)
		--Declare layer element variables
		DECLARE @DWElementName  AS VARCHAR(100)
		DECLARE @DataType  AS VARCHAR(40)
		DECLARE @BusinessKeyOrder AS INT
		DECLARE @SourceElementName VARCHAR(MAX)	
		DECLARE @PrimaryKeyOrder  AS INT
		DECLARE @ForeignKeyTable  AS VARCHAR(100)
		DECLARE @ForeignKeyTableKey AS VARCHAR(100)
		DECLARE @DWElementDesc  AS VARCHAR(4000)

		--Load Layer Object Metadata
		if object_id ('tempdb..#DWObjectList' ) is not null
		   DROP TABLE #DWObjectList

		CREATE TABLE #DWObjectList (
			CreateErrorTable INT
			,DWObjectName varchar(100)
			,DWObjectID varchar(100)
			,SchemaName varchar(40)
			,DWLayerAbbreviation varchar(40)
			,DWObjectTypeExt varchar(40)
			,DWObjectDESC varchar(4000)
			,SynonymOnly int NULL
		) 

		--Create list of DWobjects to build
		INSERT INTO #DWObjectList
		SELECT 
			CASE 
				WHEN 
					DWObjectType.DWObjectTypeID LIKE '%FACT%'
					--change back to below code when we have worked out simple snapshot patters
					--(SELECT COUNT(*) FROM dbo.DWElement DWElement WHERE DWElement.DWObjectID = DWObject.DWObjectID AND DWElement.EntityLookupObjectID IS NOT NULL) >= 1
					AND DWObjectType.DWObjectTypeID NOT IN ('DIM-SCD1', 'DIM-SCD2', 'DIM-STATIC')
					THEN 1
				ELSE 0
			END AS CreateErrorTable,
			DWObject.DWObjectName, 
			DWObject.DWObjectID,
			DWObject.DWLayerID AS SchemaName,
			DWLayer.DWLayerAbbreviation AS DWLayerAbbreviation,
			CASE 
				WHEN DWObjectType.DWObjectGroup LIKE '%Dim%' THEN 'Dim'
				WHEN DWObjectType.DWObjectGroup LIKE '%Fact%' THEN 'Fact'
				ELSE 'Unk'
			END AS DWObjectTypeExt, 
			DWObject.DWObjectDesc,
			CASE WHEN (DWObjectType.DWObjectLoadLogic = 'none') THEN 1 ELSE 0 END AS SynonymOnly
		FROM
			dbo.DWObject DWObject
			INNER JOIN dbo.DWLayer DWLayer
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWObjectType DWObjectType
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
		WHERE 
			DWLayer.DWLayerType = 'BASE' AND DWObject.IncludeInBuild = 1

		--Get Distinct of Schemas 
		if object_id ('tempdb..#DWSchemaList_temp' ) is not null
		   DROP TABLE #DWSchemaList_temp


		SELECT 
			DISTINCT SchemaName
		INTO #DWSchemaList_temp
		FROM
			(SELECT 'ext_' + SchemaName AS SchemaName
			FROM
				#DWObjectList
			WHERE SynonymOnly = 0
			UNION ALL
			SELECT 'err_' + SchemaName
			FROM
				#DWObjectList
			WHERE SynonymOnly = 0		
			UNION ALL
			SELECT 	DWLayerAbbreviation
			FROM #DWObjectList) t


		--Build Schema Script
		WHILE (SELECT COUNT(*) FROM #DWSchemaList_temp) > 0
			BEGIN
				SELECT TOP 1 
					@SchemaName = SchemaName
				FROM #DWSchemaList_temp 

				SELECT @Sql_DW_Schemas = @Sql_DW_Schemas + '
PRINT N''Creating Schema ' + @SchemaName + '...''
GO

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @SchemaName + ''')
	execute(''CREATE SCHEMA ' + @SchemaName + ' AUTHORIZATION dbo'')
GO

'
				--Delete processed row from tablelist
				DELETE FROM #DWSchemaList_temp WHERE SchemaName = @SchemaName
			END

	--Create Table List for Error and Extract Tables 
		if object_id ('tempdb..#TableList' ) is not null
		   DROP TABLE #TableList
	   		
		SELECT 
			*
		INTO #TableList
		FROM #DWObjectList

		--Loop Through Table list
		WHILE (SELECT COUNT(*) FROM #TableList) > 0
			BEGIN
				SELECT TOP 1 
					@CreateErrorTable = CreateErrorTable,
					@DWObjectName = DWObjectName,
					@DWObjectID = DWObjectID,
					@SchemaName = SchemaName,
					@DWLayerAbbreviation = DWLayerAbbreviation,
					@DWObjectTypeExt = DWObjectTypeExt,
					@DWObjectDESC = COALESCE(DWObjectDESC,''),
					@SynonymOnly = SynonymOnly
				FROM #TableList 
				ORDER BY SchemaName, DWObjectName


				SELECT @FullExtractTableName = 'ext_' + @SchemaName + '.' + @DWObjectName
				SELECT @FullErrorTableName = 'err_' + @SchemaName + '.' + @DWObjectName

				--Skip if only a synonym
				IF (@SynonymOnly = 0)
				BEGIN
					--Load Layer Element Metadata
					if object_id ('tempdb..#ExtractLayerElements' ) is not null
					   DROP TABLE #ExtractLayerElements

					--Load Layer Elements Object Metadata
					SELECT TOP 0 1 AS RowID, DWElementName, DataType, BusinessKeyOrder, DWElementDesc
					INTO #ExtractLayerElements
					FROM dbo.DWElement DWElement
						INNER JOIN dbo.DomainDataType DomainDataType ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID 

					CREATE CLUSTERED INDEX IX_ExtractLayerElements
					ON #ExtractLayerElements 
					(
						RowID ASC
					)

					--Load Extract Layer element metadata into temp table

					INSERT INTO #ExtractLayerElements
					SELECT 
						Row_Number() OVER (ORDER BY COALESCE(BusinessKeyOrder , 999), DWElementName) AS RowID,	
						DWElementName, DataType, BusinessKeyOrder,  DWElementDesc
					FROM
						(SELECT *
								--,1000 + (ROW_NUMBER() OVER (ORDER BY DWElementName)) AS ElementOrder	
						FROM dbo.DWElement
						WHERE 
							DWObjectID = @DWObjectID) DWElement
						INNER JOIN dbo.DomainDataType DomainDataType ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID 
					ORDER BY 
						COALESCE(BusinessKeyOrder , 999)
							,DWElementName
						

					WHILE (SELECT COUNT(*) FROM #ExtractLayerElements) > 0
					BEGIN
						SELECT TOP 1 
							@DWElementName = COALESCE(DWElementName,''),
							@DataType = COALESCE(DataType,''),
							@BusinessKeyOrder = COALESCE(BusinessKeyOrder, 999),
							@DWElementDesc = COALESCE(DWElementDesc, '')					
						FROM #ExtractLayerElements 		

						SELECT @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
			'

						IF (@BusinessKeyOrder  > 1)
							BEGIN
								SELECT @Sql_Extract_Mapping = @Sql_Extract_Mapping + ','
							END

						IF (@BusinessKeyOrder  = 1)
							BEGIN
								SELECT @Sql_Extract_BK = @Sql_Extract_BK + @DWElementName + ' ASC'
							END
						ELSE IF (@BusinessKeyOrder  < 999)
							BEGIN
								SELECT @Sql_Extract_BK = @Sql_Extract_BK + '
				,' + @DWElementName + ' ASC'
							END

						SELECT @Sql_Extract_Mapping = @Sql_Extract_Mapping + @DWElementName + ' ' + @DataType + 
							(CASE WHEN (@BusinessKeyOrder < 999) THEN ' NOT NULL' ELSE ' NULL' END) 				
					
						DELETE FROM #ExtractLayerElements WHERE DWElementName = @DWElementName
					END							

					SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Table Containing data for ' + @DWObjectName + ': ' + @DWObjectDESC + ''', 
			@level0type = N''SCHEMA'', @level0name = ''ext_' + @SchemaName + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectName + ''';
		GO
'

						--Build Extract Header and Footer
						SELECT @Sql_Extract_Header = 
	'

		------------------------------------------------------------------
		-- Printing Table ' + @FullExtractTableName + '
		------------------------------------------------------------------
PRINT N''Dropping Table ' + @FullExtractTableName + '...''
GO

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullExtractTableName + ''') AND type in (N''U''))
			DROP TABLE ' + @FullExtractTableName + '
		GO

PRINT N''Creating Table ' + @FullExtractTableName + '...''
GO

		SET ANSI_NULLS ON
		GO

		SET QUOTED_IDENTIFIER ON
		GO

		CREATE TABLE ' + @FullExtractTableName + ' ( '		


						SELECT @Sql_Extract_Footer= 
	'
			,LoadTime datetime NOT NULL
			,LastChangeTime datetime NULL
			,ExtractJobID int NOT NULL
			,SourceIdentifier nvarchar(40) NULL
			,CONSTRAINT PK_Ext_' + @SchemaName + '_' + @DWObjectName + '_EJID_BK PRIMARY KEY CLUSTERED 
			(
				ExtractJobID ASC
				,' + @Sql_Extract_BK + '
			) 
		)   WITH (DATA_COMPRESSION = ' + @CompressionType + ')  

		GO

PRINT N''Creating NonClustered Index IX_Ext_' + @SchemaName + '_' + @DWObjectName + '_LT_EJID...''
GO

		CREATE NONCLUSTERED INDEX IX_Ext_' + @SchemaName + '_' + @DWObjectName + '_LT_EJID ON ' + @FullExtractTableName + ' 
		(
			LoadTime ASC
			,ExtractJobID ASC
		)   WITH (DATA_COMPRESSION = ' + @CompressionType + ')  
		GO

PRINT N''Altering Table ' + @FullExtractTableName + '  Adding  Constraint DF_Ext_' + @SchemaName + '_' + @DWObjectName + '_LoadTime...''
GO

		ALTER TABLE ' + @FullExtractTableName + '  ADD  CONSTRAINT DF_Ext_' + @SchemaName + '_' + @DWObjectName + '_LoadTime  DEFAULT (getdate()) FOR LoadTime
		GO
	'
					--If Required Build Error Header and Footer
					IF (@CreateErrorTable = 1)
						BEGIN
							SELECT @Sql_Error_Header = 	
	'

		------------------------------------------------------------------
		-- Printing Table ' + @FullErrorTableName + '
		------------------------------------------------------------------
PRINT N''Dropping Table ' + @FullErrorTableName + '...''
GO

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @FullErrorTableName + ''') AND type in (N''U''))
			DROP TABLE ' + @FullErrorTableName + '
		GO

PRINT N''Creating Table ' + @FullErrorTableName + '...''
GO

		SET ANSI_NULLS ON
		GO

		SET QUOTED_IDENTIFIER ON
		GO

		CREATE TABLE ' + @FullErrorTableName + ' ('

						SELECT @Sql_Error_Footer = 	
	'
			,LoadTime datetime NOT NULL
			,LastChangeTime datetime NULL
			,ExtractJobID int NOT NULL
			,SourceIdentifier nvarchar(40) NULL
			,ErrType nvarchar(50) NULL
			,ErrMessage nvarchar(max) NULL
			,CONSTRAINT PK_Err_' + @SchemaName + '_' + @DWObjectName + '_BK PRIMARY KEY CLUSTERED 
			(
				' + @Sql_Extract_BK + '
			) 
		)   WITH (DATA_COMPRESSION = ' + @CompressionType + ')  
		GO

PRINT N''Altering Table ' + @FullErrorTableName + '  Adding  Constraint DF_Ext_' + @SchemaName + '_' + @DWObjectName + '_LoadTime...''
GO

		ALTER TABLE ' + @FullErrorTableName + ' ADD  CONSTRAINT DF_Err_' + @SchemaName + '_' + @DWObjectName + '_LoadTime  DEFAULT (getdate()) FOR LoadTime
		GO
	'
							SELECT @Sql_Error = @Sql_Error + @Sql_Error_Header + @Sql_Extract_Mapping + @Sql_Error_Footer
							SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Table Containing from ' + @FullExtractTableName + ' Which would not load into the destination table'', 
			@level0type = N''SCHEMA'', @level0name = ''Err_' + @SchemaName + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @DWObjectName + ''';
		GO
'

						END	
				END

				--Build Synonym
				SELECT @Sql_Synonym = @Sql_Synonym + '

	------------------------------------------------------------------
	-- Printing synonym ' + @DWLayerAbbreviation + '.' + @DWObjectName + ' 
	------------------------------------------------------------------
PRINT N''Dropping Synonym ' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + '...''
GO

	IF  EXISTS (SELECT * FROM sys.synonyms syn INNER JOIN sys.schemas sch ON syn.schema_id = sch.schema_id WHERE sch.name = N''' + @DWLayerAbbreviation + '''  AND syn.name = N''' + @DWObjectTypeExt + @DWObjectName + ''')
		DROP SYNONYM ' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + '
	GO

PRINT N''Creating Synonym ' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + ' For ' + @DWData_TargetDB + '.' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + '...''
GO

	CREATE SYNONYM ' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + ' FOR ' + @DWData_TargetDB + '.' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + '
	GO
'	

				SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] Synonym for ' + @DWLayerAbbreviation + '.' + @DWObjectTypeExt + @DWObjectName + ' Table in the DW Layer used by Delivery Stored Procs'', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''SYNONYM'',  @level1name = ''' + @DWObjectTypeExt + @DWObjectName + ''';
		GO
'

				--Join together header, mapping and footer
				SELECT @Sql_Extract = @Sql_Extract + @Sql_Extract_Header + @Sql_Extract_Mapping + @Sql_Extract_Footer

				--Delete processed row from tablelist
				DELETE FROM #TableList WHERE DWObjectID = @DWObjectID

				--reset variables

				SELECT @Sql_Extract_Header = ''
				SELECT @Sql_Extract_Mapping = ''
				SELECT @Sql_Extract_Footer = ''
				SELECT @Sql_Extract_BK = ''	
			
				SELECT @Sql_Error_Header = ''
				SELECT @Sql_Error_Footer = ''

			END
		
			--print dynamic sql

		SELECT @Sql_Extract_ALL = '
USE ' + @DWExtract_ModelDB + '
GO

-----------------------------------------
--Printing Schemas
-----------------------------------------
'	+ COALESCE(@Sql_DW_Schemas,'') + '
-----------------------------------------
--Printing Extract Tables
-----------------------------------------
'	+ COALESCE(@Sql_Extract,'') + '
-----------------------------------------
--Printing Error Tables
-----------------------------------------
'	+ COALESCE(@Sql_Error,'') + '
-----------------------------------------
--Printing Synonyms
-----------------------------------------
'	+ COALESCE(@Sql_Synonym,'') + '
-----------------------------------------
--Printing Extended Properties
-----------------------------------------
'	+ COALESCE(@Sql_DW_ExtendedProps,'')   
						

		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Extract_Objects'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT 2, 'DW_Extract_Objects', @Sql_Extract_ALL
		END
		
		EXEC dbo.udpLongPrint @Sql_Extract_ALL
		
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