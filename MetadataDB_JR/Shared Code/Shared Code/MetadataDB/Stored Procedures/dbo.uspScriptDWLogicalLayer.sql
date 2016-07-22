









-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWLogicalLayer]
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

		DECLARE @MappingInstanceID AS VARCHAR(40) = 'dw_to_logical'
		DECLARE @Sql_ALL AS VARCHAR(MAX) = ''

		--Declare Script Variables
		DECLARE @Sql_Schemas AS VARCHAR(MAX) = '',
				@Sql_Functions AS VARCHAR(MAX) = '',
				@Sql_LogicalLayerObjects AS VARCHAR(MAX) = '',
				@Sql_LogicalLayerObject AS VARCHAR(MAX) = ''

		--Declare Schema Level Variables
		DECLARE	@DWLayerAbbreviation AS VARCHAR(40) = ''

		--Declare Mapping Level Variables
		DECLARE @MappingID AS VARCHAR(100) = '',
				@SourceChangeType AS VARCHAR(MAX) 

		if object_id ('tempdb..#Mapping' ) is not null
		   DROP TABLE #Mapping

		SELECT
			Mapping.MappingID,
			DWLayer.DWLayerAbbreviation,
			SourceChangeType.SourceChangeType,
			MappingSetMapping.BuildOrder
		INTO #Mapping
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
			INNER JOIN dbo.DWLayer
				ON DWObject.DWLayerID = DWLayer.DWLayerID 
			INNER JOIN dbo.SourceChangeType SourceChangeType
				ON Mapping.DefaultSourceChangeTypeID = SourceChangeType.SourceChangeTypeID
		WHERE
			Mapping.TargetTypeID = 'dw' AND
			MappingInstance.MappingInstanceID = @MappingInstanceID AND
			DWObject.IncludeInBuild = 1

		--Get Distinct of Schemas 
		if object_id ('tempdb..#DWSchemaList' ) is not null
		   DROP TABLE #DWSchemaList

		SELECT DISTINCT DWLayerAbbreviation
			INTO #DWSchemaList
		FROM
			#Mapping

		--Build Schema Script
		WHILE (SELECT COUNT(*) FROM #DWSchemaList) > 0
			BEGIN
				SELECT TOP 1 
					@DWLayerAbbreviation = DWLayerAbbreviation
				FROM #DWSchemaList 

				SELECT @Sql_Schemas = @Sql_Schemas + '
PRINT N''Creating Schema ' + @DWLayerAbbreviation + '...''
GO


IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @DWLayerAbbreviation + ''')
	execute(''CREATE SCHEMA ' + @DWLayerAbbreviation + ' AUTHORIZATION dbo'')
GO

'
				--Delete processed row from tablelist
				DELETE FROM #DWSchemaList WHERE DWLayerAbbreviation = @DWLayerAbbreviation
			END

		
		WHILE (SELECT COUNT(*) FROM #Mapping) > 0
		BEGIN
			SELECT TOP 1
				@MappingID = MappingID,
				@SourceChangeType = SourceChangeType 
			FROM
				#Mapping
			ORDER BY BuildOrder, MappingID

			IF (@SourceChangeType = 'View') 
			BEGIN 
				execute [dbo].[uspScriptDWLogicalLayer_Views] @Environment, @MappingID, @OutputSQL = @Sql_LogicalLayerObject OUTPUT;
			END
			ELSE IF (@SourceChangeType = 'Snapshot') 
			BEGIN 
				execute [dbo].[uspScriptDWLogicalLayer_Snapshots] @Environment, @MappingID, @OutputSQL = @Sql_LogicalLayerObject OUTPUT;
			END
			ELSE IF (@SourceChangeType = 'Delta') 
			BEGIN 
				execute [dbo].[uspScriptDWLogicalLayer_Deltas] @Environment, @MappingID, @OutputSQL = @Sql_LogicalLayerObject OUTPUT;
			END

			SELECT @Sql_LogicalLayerObjects = @Sql_LogicalLayerObjects + COALESCE(@Sql_LogicalLayerObject,'')

			SELECT @Sql_LogicalLayerObject = ''

			DELETE FROM #Mapping WHERE MappingID = @MappingID
		END

		SELECT @Sql_Functions = ''


		SELECT @Sql_ALL = '
USE ' + @DWData_ModelDB + '
GO

-----------------------------------------
--Printing Schemas
-----------------------------------------
'	+ COALESCE(@Sql_Schemas,'') + '
-----------------------------------------
--Printing Shared Functions
-----------------------------------------
'	+ COALESCE(@Sql_Functions,'') + '
-----------------------------------------
--Printing DW Logical Layer Views
-----------------------------------------
'	+ COALESCE(@Sql_LogicalLayerObjects,'')


		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Logical_Layer'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT 4, 'DW_Logical_Layer', @Sql_ALL
		END
		
		EXEC dbo.udpLongPrint @Sql_ALL



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