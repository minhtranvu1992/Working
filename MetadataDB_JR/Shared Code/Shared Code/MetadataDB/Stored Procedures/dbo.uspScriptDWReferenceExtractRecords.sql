








-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWReferenceExtractRecords]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @DWReference_ModelDB AS VARCHAR(100)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		DECLARE @SuiteName AS VARCHAR(MAX) = ''
		DECLARE @MappingID AS VARCHAR(MAX) = ''
		DECLARE @PreviousMappingID AS VARCHAR(MAX) = ''
		DECLARE @ExtractPackageName AS NVARCHAR(MAX) = ''
		DECLARE @ExtractTable AS VARCHAR(MAX) = ''
		DECLARE @ExtractProcessType VARCHAR(MAX) = ''
		DECLARE @ETLImplementationTypeID VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		DECLARE @SourceQuery NVARCHAR(MAX) 
		DECLARE @SourceQueryMapping NVARCHAR(MAX) 

		IF OBJECT_ID ('tempdb..#ExtractPackage_List' ) IS NOT NULL
		   DROP TABLE #ExtractPackage_List

		SELECT 
			 Mapping.MappingID,
			 --In the case where we have two or more mappings from the same mapping set that get mapped to the same DWObject, we need to create a seperate ExtractPackageName to
			 --allow us to split out the control for this extra load. In this case we require one of those objects to have a value in the Mapping.AlternatePackageName Field. This
			 --Value will get used as the ExtractPackageName in preference to the default ExtractPackageName.
			CASE wHEN COALESCE(Mapping.AlternatePackageName,'') = '' THEN ('extract_' + DWObjectID) ELSE ('extract_' + Mapping.AlternatePackageName) END AS ExtractPackageName,
			Connection.SuiteName AS SuiteName,
			('[ext_' + DWLayer.DWLayerID + '].[' + DWObjectName + ']') AS ExtractTable,
			--COALESCE(MappingInstanceMapping.OverrideETLImplementationTypeID, Mapping.DefaultETLImplementationTypeID) AS ETLImplementationTypeID,
			Mapping.DefaultETLImplementationTypeID AS ETLImplementationTypeID,
			ETLImplementationType.[ExtractProcessType]
		INTO #ExtractPackage_List
		FROM dbo.DWLayer DWLayer 
			INNER JOIN dbo.DWObject DWObject 
				ON DWLayer.DWLayerID = DWObject.DWLayerID
			INNER JOIN dbo.Mapping Mapping 
				ON Mapping.TargetObjectID = DWObjectID
			INNER JOIN dbo.MappingSetMapping 
				ON Mapping.MappingID = MappingSetMapping.MappingID 
		     INNER JOIN dbo.MappingInstance MappingInstance
				ON MappingSetMapping.MappingSetID = MappingInstance.MappingSetID
			LEFT JOIN dbo.ETLImplementationType ETLImplementationType
				ON ETLImplementationType.ETLImplementationTypeID = Mapping.DefaultETLImplementationTypeID
			LEFT JOIN dbo.Connection Connection
				ON MappingInstance.SourceConnectionID = Connection.ConnectionID
		WHERE 
			DWLayerType = 'Base'
			AND DWObject.IncludeInBuild = 1
			AND MappingInstance.IncludeInBuild = 1
			AND DWLayer.DWLayerID <> 'ref'
			AND Connection.SuiteName IS NOT NULL

		WHILE (SELECT COUNT(*) FROM #ExtractPackage_List) > 0
		BEGIN
			SELECT TOP 1 
				@SuiteName = SuiteName,
				@MappingID = MappingID,
				@ExtractPackageName = ExtractPackageName,
				@ExtractTable = ExtractTable,
				@ExtractProcessType = ExtractProcessType,
				@ETLImplementationTypeID = ETLImplementationTypeID
			FROM #ExtractPackage_List 
			ORDER BY MappingID, SuiteName

			IF @PreviousMappingID <> @MappingID
			BEGIN
				SET @SourceQuery = NULL
				SET @SourceQueryMapping = NULL
				
				IF @ETLImplementationTypeID IN ('SP_Bulkload', 'SQL_Bulkload') AND @PreviousMappingID <> @MappingID
				BEGIN
    				    EXEC [dbo].[uspScriptSourceObject_Extract] @MappingID = @MappingID, @SourceQuery = @SourceQuery OUTPUT, @SourceQueryMapping = @SourceQueryMapping OUTPUT, @ExtractPackageName = @ExtractPackageName
				END
			 END

			SELECT @SQL_Print = @SQL_Print + 
'INSERT INTO [dbo].[ExtractControl] ([ExtractPackageName], [ExtractPackagePath], [ProcessType], [SuiteName], [SourceQuery], [SourceQueryMapping], [ExtractTable], [ExecutionOrder], [ExecutionOrderGroup], [ExtractStartTime], [LastExtractJobID])
VALUES  (''' + @ExtractPackageName + ''' ,''\DWExtract'' ,''' + @ExtractProcessType + '''  ,''' + @SuiteName + ''', '
+ (CASE WHEN COALESCE(@SourceQuery, '"') = '"' THEN 'NULL' ELSE '''' + REPLACE(@SourceQuery,'''', '''''') + '''' END)  + '  ,' 
+ (CASE WHEN COALESCE(@SourceQueryMapping, '"') = '"' THEN 'NULL' ELSE '''' + REPLACE(@SourceQueryMapping,'''', '''''') + '''' END)
+ ' ,''' + @ExtractTable + ''', 1, 1, GETDATE(), 1)
GO
'					
		    SET @PreviousMappingID = @MappingID

		--Delete processed row from tablelist
			DELETE FROM #ExtractPackage_List WHERE  @SuiteName = SuiteName AND @MappingID = MappingID

		END

		--print dynamic sql
		SELECT @SQL_Print = '
USE ' + @DWReference_ModelDB + '
GO

PRINT N''Start Inserting ExtractControl Records...''
GO

-----------------------------------------
--Printing InsertSQL
-----------------------------------------
'	+ COALESCE(@SQL_Print,'')  + '

PRINT N''Finished Inserting ExtractControl Records...''
GO

'
						
		EXEC dbo.udpLongPrint @SQL_Print
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