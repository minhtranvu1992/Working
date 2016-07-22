


-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWStagingObjects]
(
	@Environment AS VARCHAR(100) = 'Model',
	@DWStaging_ModelDB AS VARCHAR(100)
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

	   DECLARE @CompressionType AS VARCHAR(100)
	   DECLARE @DWReference_TargetDB AS VARCHAR(MAX) = ''
	   DECLARE @Sql_Staging_All AS VARCHAR(MAX) = ''
	   DECLARE @Sql_DW_Schemas AS VARCHAR(MAX) = ''
	   DECLARE @SchemaName AS VARCHAR(MAX) = ''

	   DECLARE @Sql_StagingObjects AS VARCHAR(MAX) = ''
	   DECLARE @Sql_StagingTables_ODS AS VARCHAR(MAX) = ''
	   DECLARE @Sql_StagingTables_STG AS VARCHAR(MAX) = ''
	   DECLARE @Sql_StagingMergeProc AS VARCHAR(MAX) = ''
	   DECLARE @Sql_StagingXMLTableType AS VARCHAR(MAX) = ''
	   DECLARE @Sql_StagingXMLSchema AS VARCHAR(MAX) = ''

	   --Declare feed variables
	   DECLARE @StagingObjectID AS VARCHAR(MAX)
	   DECLARE @StagingObjectName AS VARCHAR(MAX)
	   DECLARE @StagingOwnerID AS VARCHAR(MAX)
	   DECLARE @StagingObjectTypeID AS VARCHAR(MAX)
	   DECLARE @AlternatePackageName AS VARCHAR(MAX)

	   DECLARE @FullStagingObjectName AS VARCHAR(MAX)
	   DECLARE @StagingJobIDDataType AS VARCHAR(MAX)

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


	   --Get Distinct of Schemas 
	   If object_id ('tempdb..#DWSchemaList_temp' ) is not null
		  DROP TABLE #DWSchemaList_temp


	   --Create list of DWobjects to build
	   SELECT 
	   DISTINCT StagingOwnerSuffix AS SchemaName
	   INTO #DWSchemaList_temp
	   FROM
		  dbo.StagingOwner StagingOwner
		  LEFT JOIN dbo.StagingObject StagingObject
			 ON StagingOwner.StagingOwnerID = StagingObject.StagingOwnerID
	   WHERE 
		  StagingObject.IncludeInBuild = 1


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


	   --Load Feed Metadata
	   if object_id ('tempdb..#StagingObjects' ) is not null
	   DROP TABLE #StagingObjects

	   SELECT
		  StagingObjectID
		  ,StagingObjectName
		  ,StagingOwner.StagingOwnerID
		  ,StagingObjectDesc
		  ,StagingObjectTypeID
	   INTO #StagingObjects
	   FROM dbo.StagingObject StagingObject
    		  INNER JOIN dbo.StagingOwner StagingOwner ON StagingObject.StagingOwnerID = StagingOwner.StagingOwnerID
	   WHERE IncludeInBuild = 1
	   ORDER BY StagingObjectID


	   --Iterate through Feed Metadata	
	   WHILE (SELECT COUNT(*) FROM #StagingObjects) > 0
	   BEGIN
		  SELECT TOP 1 
			 @StagingObjectID = StagingObjectID,
			 @StagingObjectName = StagingObjectName,
			 @StagingOwnerID = StagingOwnerID,
			 @StagingObjectTypeID = StagingObjectTypeID
		  FROM  #StagingObjects 


		  --Both FlatFile_BulkLoad and SQL_BulkLoad produce the same Staging Objects
		  IF (@StagingObjectTypeID = 'Batch' )
		  BEGIN 
			 --create STG and ODS table for Staging Entity
			 EXECUTE [dbo].[uspScriptDWStagingTableBatch_ODS] @CompressionType, @StagingObjectID, @OutputSQL = @Sql_StagingTables_ODS OUTPUT;	
			 		 
			 --Load Feed Metadata
			 if object_id ('tempdb..#AlternatePackageNames' ) is not null
			 DROP TABLE #AlternatePackageNames

			 SELECT 
				 COALESCE(AlternatePackageName, '') AS AlternatePackageName
			 INTO #AlternatePackageNames
			 FROM
				dbo.Mapping Mapping
			 WHERE
				TargetObjectID = @StagingObjectID	

	   		 SELECT @Sql_StagingObjects = @Sql_StagingObjects + COALESCE(@Sql_StagingTables_ODS,'') 

			 WHILE (SELECT COUNT(*) FROM #AlternatePackageNames) > 0
			 BEGIN
				SELECT TOP 1 @AlternatePackageName = AlternatePackageName
				FROM #AlternatePackageNames

				EXECUTE [dbo].[uspScriptDWStagingTableBatch_STG] @CompressionType, @StagingObjectID, @AlternatePackageName, @OutputSQL = @Sql_StagingTables_STG OUTPUT;			 
				EXECUTE [dbo].[uspScriptDWStagingBatchMergeProcs] @StagingObjectID, @AlternatePackageName, @OutputSQL = @Sql_StagingMergeProc OUTPUT;

				DELETE FROM #AlternatePackageNames WHERE AlternatePackageName = @AlternatePackageName

	   			SELECT @Sql_StagingObjects = @Sql_StagingObjects + COALESCE(@Sql_StagingTables_STG,'') + COALESCE(@Sql_StagingMergeProc,'')

			 END
		  END
		  ELSE IF (@StagingObjectTypeID = 'XMLMessage') 
		  BEGIN 
			 EXECUTE [dbo].[uspScriptDWStagingTable_Message] @CompressionType, @StagingObjectID, @OutputSQL = @Sql_StagingTables_ODS OUTPUT;
			 EXECUTE [dbo].[uspScriptDWStagingXMLTableType] @StagingObjectID, @OutputSQL = @Sql_StagingXMLTableType OUTPUT; 
			 EXECUTE [dbo].[uspScriptDWStagingXMLSchema] @StagingObjectID, @OutputSQL = @Sql_StagingXMLSchema OUTPUT; 
			 EXECUTE [dbo].[uspScriptDWStagingXMLMergeProcs] @StagingObjectID, @OutputSQL = @Sql_StagingMergeProc OUTPUT;
	   		 
			 SELECT @Sql_StagingObjects = @Sql_StagingObjects + COALESCE(@Sql_StagingTables_ODS,'') + COALESCE(@Sql_StagingXMLTableType,'') + COALESCE(@Sql_StagingXMLSchema,'') + COALESCE(@Sql_StagingMergeProc,'')
		  END


    		  SELECT @Sql_StagingTables_ODS = ''
    		  SELECT @Sql_StagingTables_STG = ''
    		  SELECT @Sql_StagingMergeProc = ''
    		  SELECT @Sql_StagingXMLTableType = ''
		  SELECT @Sql_StagingXMLSchema = ''

		  DELETE FROM #StagingObjects WHERE StagingObjectID = @StagingObjectID

	   END	

	   SELECT @Sql_Staging_ALL = '
USE ' + @DWStaging_ModelDB + '
GO ' +
' 
-----------------------------------------
--Printing Schemas
-----------------------------------------
'	
+ COALESCE(@Sql_DW_Schemas,'') 
+ '
-----------------------------------------
--Printing Staging Tables
-----------------------------------------
'	
+ COALESCE(@Sql_StagingObjects,'') 
						

		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Staging_Objects'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT 0, 'DW_Staging_Objects', @Sql_Staging_ALL
		END
		
		EXEC dbo.udpLongPrint @Sql_Staging_ALL
		
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