









-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWLogicalLayer_Snapshots]
	@Environment AS VARCHAR(100) = 'Model',
	@MappingID VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
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

		--Declare Script Variables
		DECLARE 
			@Sql_Proc AS VARCHAR(MAX) = '',
			@Sql_Table AS VARCHAR(MAX) = '',
			@Sql_ProcName AS VARCHAR(MAX) = '',
			@Sql_TableName AS VARCHAR(MAX) = '',
			@Sql_ProcInsertElement AS VARCHAR(MAX) = '',
			@Sql_ProcElementMapping AS VARCHAR(MAX) = '',
			@Sql_TableElementMapping AS VARCHAR(MAX) = '',
			@Sql_KeyList AS VARCHAR(MAX) = '',
			@Sql_ColumnMetadata AS VARCHAR(MAX) = ''

		--Declare Schema Level Variables
		DECLARE	@DWLayerAbbreviation AS VARCHAR(40) = ''

		--Declare Mapping Level Variables
		DECLARE 
			@DWObjectName AS VARCHAR(100) = '',
			@DWObjectDesc AS VARCHAR(MAX) = '',
			@DWObjectGroupAbbreviation AS VARCHAR(40) = '',
			@DWObjectLoadLogic AS VARCHAR(40) = '',
			@SourceObjectLogic AS VARCHAR(MAX),
			@PreObjectLogic AS VARCHAR(MAX) = '',
			@PostObjectLogic AS VARCHAR(MAX) = ''

		--Declare Element Level Variables
		DECLARE 
			@DWElementID AS VARCHAR(100) = '',
			@DWElementDesc AS VARCHAR(MAX) = '',
			@SourceElementLogic AS VARCHAR(MAX) = '',	
			@DWElementName AS VARCHAR(100) = '',
			@ElementCount AS INT = 0,
			@DataType AS VARCHAR(MAX) = '',
			@BusinessKeyOrder AS INT = 0,
			@EntityLookupObjectID AS VARCHAR(MAX) = ''

		SELECT
			@MappingID = Mapping.MappingID,
			@DWObjectName = DWObject.DWObjectName,
			@DWObjectDesc = REPLACE(COALESCE(DWObject.DWObjectDesc, ''), '''', ''''''), 
			@DWLayerAbbreviation = DWLayer.DWLayerAbbreviation,
			@DWObjectLoadLogic = DWObjectType.DWObjectLoadLogic,
			@DWObjectGroupAbbreviation = DWObjectType.DWObjectGroupAbbreviation,
			@SourceObjectLogic = Mapping.SourceObjectLogic,
			@PreObjectLogic = COALESCE(Mapping.PreMappingLogic,''),
			@PostObjectLogic = COALESCE(Mapping.PostMappingLogic,'')
		FROM 
			dbo.MappingInstance MappingInstance
			INNER JOIN dbo.MappingSet MappingSet
				ON MappingInstance.MappingSetID = MappingSet.MappingSetID
			INNER JOIN dbo.MappingSetMapping MappingSetMapping
				ON MappingSet.MappingSetID = MappingSetMapping.MappingSetID
			INNER JOIN dbo.Mapping Mapping
				ON MappingSetMapping.MappingID = Mapping.MappingID
			INNER JOIN dbo.DWObject DWObject
				ON Mapping.TargetObjectID = DWObject.DWObjectID
			INNER JOIN dbo.DWObjectType
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer
				ON DWObject.DWLayerID = DWLayer.DWLayerID 
		WHERE
			Mapping.MappingID = @MappingID

		if object_id ('tempdb..#MappingElement' ) is not null
			   DROP TABLE #MappingElement
			
		SELECT 		
			Row_Number() OVER (ORDER BY COALESCE(DWElement.BusinessKeyOrder, 999), (CASE WHEN DWElementName IN ('LoadTime', 'LastUpdateTime') THEN 'ZZZ' + DWElementName ELSE DWElementName END)) AS RowID,
			DWElement.DWElementID,
			DWElement.DWElementDesc,
			MappingElement.SourceElementLogic,
			DWElement.DWElementName,
			DomainDataType.DataType,
			COALESCE(DWElement.BusinessKeyOrder, 999) AS BusinessKeyOrder,
			DWObject.DWObjectID AS EntityLookupObjectID
		INTO #MappingElement
		FROM 
			dbo.MappingElement MappingElement
			INNER JOIN dbo.DWElement DWElement
				ON MappingElement.TargetElementID = DWElement.DWElementID
			INNER JOIN dbo.DomainDataType DomainDataType
				ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
			LEFT JOIN dbo.DWObject DWObject
				ON DWElement.EntityLookupObjectID = DWObject.DWObjectID
		WHERE 
			MappingElement.MappingID = @MappingID
			AND DWElement.DWElementName NOT IN ('LoadTime', 'LastUpdateTime')

		SELECT @Sql_ProcName = 'dbo.uspDeliver_' + @DWObjectGroupAbbreviation + @DWObjectName
		SELECT @Sql_TableName = @DWLayerAbbreviation +'.' + @DWObjectGroupAbbreviation + @DWObjectName
		SELECT @Sql_TableName = @DWObjectGroupAbbreviation + @DWObjectName

		WHILE (SELECT COUNT(*) FROM #MappingElement) > 0
		BEGIN
			SELECT TOP 1
				@DWElementID = DWElementID,
				@DWElementDesc = REPLACE(COALESCE(DWElementDesc, ''), '''', ''''''), 
				@SourceElementLogic = SourceElementLogic,
				@DWElementName = DWElementName,
				@DataType = DataType,
				@BusinessKeyOrder = BusinessKeyOrder,
				@EntityLookupObjectID = EntityLookupObjectID
			FROM #MappingElement
			ORDER BY RowID

			SELECT @ElementCount = @ElementCount + 1

			--Create Stored Procedure Mappings
			SELECT @Sql_ProcInsertElement = @Sql_ProcInsertElement + '
			' + (CASE WHEN @ElementCount = 1 THEN '' ELSE ',' END) + @DWElementName

			SELECT @Sql_ProcElementMapping = @Sql_ProcElementMapping + '
			' + (CASE WHEN @ElementCount = 1 THEN '' ELSE ',' END) + @SourceElementLogic + ' AS ' + @DWElementName

			--Create Table Mappings
			SELECT @Sql_TableElementMapping = @Sql_TableElementMapping + '
			' + (CASE WHEN @ElementCount = 1 THEN '' ELSE ',' END) + @DWElementName + ' ' + @DataType + (CASE WHEN (@EntityLookupObjectID IS NULL AND @BusinessKeyOrder = 999) THEN ' NULL' ELSE ' NOT NULL' END)   

			IF (@BusinessKeyOrder <> 999) 
			BEGIN
				SELECT @Sql_KeyList = @Sql_KeyList + '
				' + (CASE WHEN @ElementCount = 1 THEN '' ELSE ',' END) + @DWElementName + ' ASC'

			END

			--Create Column Metadata
			SELECT @Sql_ColumnMetadata = @Sql_ColumnMetadata + '		
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWElementDesc + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @Sql_TableName + ''',
			@level2type = N''COLUMN'', @level2name = ''' + @DWElementName + ''';		
		GO
		'

			DELETE FROM #MappingElement WHERE DWElementID = @DWElementID
		END


		--Create Table
		SELECT @Sql_Table = 
'	------------------------------------------------------------------
	-- Printing Table ' + @Sql_TableName + '
	------------------------------------------------------------------
PRINT N''Dropping Table ' + @DWLayerAbbreviation +'.' + @Sql_TableName + '...''
GO

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @DWLayerAbbreviation +'.' + @Sql_TableName + ''') AND type in (N''U''))
		DROP TABLE ' + @DWLayerAbbreviation +'.' + @Sql_TableName + '
		GO

PRINT N''Creating Table ' + @DWLayerAbbreviation +'.' + @Sql_TableName + '...''
GO

		SET ANSI_NULLS ON
		GO

		SET QUOTED_IDENTIFIER ON
		GO

		CREATE TABLE ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' (' + @Sql_TableElementMapping + '
			,LoadTime smalldatetime NOT NULL
			,LastUpdateTime smalldatetime NOT NULL
			,DeliveryJobID int NOT NULL
			,CONSTRAINT PK_' + @Sql_TableName + ' PRIMARY KEY CLUSTERED 
			(' + @Sql_KeyList + '
			)
		)   WITH (DATA_COMPRESSION = ' + @CompressionType + ')  
		GO

PRINT N''Altering Table ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' Adding  Constraint DF_' + @Sql_TableName + '_LoadTime...''
GO

		ALTER TABLE ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' ADD  CONSTRAINT DF_' + @Sql_TableName + '_LoadTime  DEFAULT (getdate()) FOR LoadTime
		GO

PRINT N''Altering Table ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' Adding  Constraint DF_' + @Sql_TableName + '_LastUpdateTime...''
GO

		ALTER TABLE ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' ADD  CONSTRAINT DF_' + @Sql_TableName + '_LastUpdateTime  DEFAULT (getdate()) FOR LastUpdateTime
		GO

		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWObjectDesc + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''TABLE'',  @level1name = ''' + @Sql_TableName + ''';
		GO
'		+ @Sql_ColumnMetadata



			SELECT @Sql_Proc = '
PRINT N''Dropping Procedure ' + @Sql_ProcName + '...''
GO
			
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Sql_ProcName + ''') AND type in (N''P'', N''PC''))
DROP PROCEDURE ' + @Sql_ProcName + '
GO				

PRINT N''Creating Procedure ' + @Sql_ProcName + '...''
GO
			
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================================================
-- *** CREATED FROM Metadata, TO CHANGE UPDATE Metadata in Solution AND RECREATE ***
-- Author:		Metadata
-- Description:	This stored procedure delivers the data from the BASE dw layer to the 
--				Materialized logical table ' + @DWLayerAbbreviation +'.' + @Sql_TableName + '
--
-- ====================================================================================
CREATE PROCEDURE ' + @Sql_ProcName + '
(
	@DeliveryJobID INT,
	@StartTime DATETIME
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

	DBCC TRACEON (610) WITH NO_INFOMSGS;

	BEGIN TRY
		
		' + @PreObjectLogic + '

		TRUNCATE TABLE ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' 

		INSERT INTO ' + @DWLayerAbbreviation +'.' + @Sql_TableName + ' WITH (TABLOCK)
		(' + @Sql_ProcInsertElement + '
			,DeliveryJobID
		)
		SELECT' + @Sql_ProcElementMapping + '
			,@DeliveryJobID
		FROM ' + @SourceObjectLogic + '

		' + @PostObjectLogic + '

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

END
GO

'


		SELECT @OutputSQL = @Sql_Table + @Sql_Proc


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