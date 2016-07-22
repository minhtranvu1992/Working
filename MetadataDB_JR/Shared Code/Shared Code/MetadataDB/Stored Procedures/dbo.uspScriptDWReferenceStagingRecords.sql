


-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the Staging tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWReferenceStagingRecords]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @DWReference_ModelDB AS VARCHAR(100)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		DECLARE @SuiteName AS VARCHAR(MAX) = ''
		DECLARE @SourceName AS VARCHAR(MAX) = ''
		DECLARE @MappingID AS VARCHAR(MAX) = ''
		DECLARE @PreviousMappingID AS VARCHAR(MAX) = ''
		DECLARE @StagingPackageName AS NVARCHAR(MAX) = ''
		DECLARE @StagingTable AS VARCHAR(MAX) = ''
		DECLARE @MergeQuery AS VARCHAR(MAX) = ''
		DECLARE @ProcessType VARCHAR(MAX) = ''
		DECLARE @ETLImplementationTypeID VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		DECLARE @SourceQuery NVARCHAR(MAX) 
		DECLARE @SourceQueryMapping NVARCHAR(MAX) 
		DECLARE @HeaderCheckString NVARCHAR(MAX)
		DECLARE @Delimiter NVARCHAR(MAX) = ''
		DECLARE @FlatFileFormatString NVARCHAR(MAX) = ''
		DECLARE @HasHeader NVARCHAR(MAX) = ''
		DECLARE @HasFooter NVARCHAR(MAX) = ''


		IF OBJECT_ID ('tempdb..#StagingPackage_List' ) IS NOT NULL
		   DROP TABLE #StagingPackage_List

		SELECT 
			Mapping.MappingID,
			 --In the case where we have two or more mappings from the same mapping set that get mapped to the same StagingObject, we need to create a seperate StagingPackageName to
			 --allow us to split out the control for this extra load. In this case we require one of those objects to have a value in the Mapping.AlternatePackageName Field. This
			 --Value will get used as the StagingPackageName in preference to the default StagingPackageName.
			CASE 
			 wHEN COALESCE(Mapping.AlternatePackageName,'') = '' 
				THEN (StagingObjectName) 
			 ELSE (Mapping.AlternatePackageName) 
			END AS StagingPackageName,
			Connection.SuiteName AS SuiteName,
			Connection.SourceName AS SourceName,
			CASE 
			 wHEN COALESCE(Mapping.AlternatePackageName,'') = '' 
				THEN (StagingOwner.StagingOwnderPrefix + '.STG_' + StagingObjectName)
			 ELSE 
				(StagingOwner.StagingOwnderPrefix + '.STG_' + StagingObjectName + '_' + Mapping.AlternatePackageName)
			END AS StagingTable,
			CASE 
			 wHEN COALESCE(Mapping.AlternatePackageName,'') = '' 
				THEN (StagingOwner.StagingOwnderPrefix + '.uspUpdate_' + StagingObjectName)
			 ELSE 
				(StagingOwner.StagingOwnderPrefix + '.uspUpdate_' + StagingObjectName + '_' + Mapping.AlternatePackageName)
			END AS MergeQuery,
			Mapping.DefaultETLImplementationTypeID AS ETLImplementationTypeID,
			(CASE (Mapping.DefaultETLImplementationTypeID) 
			 WHEN 'SQL_Bulkload_Staging' THEN 'BULKSQL' 
			 WHEN 'FlatFile_Bulkload_Staging' THEN 'BULKFILE'
			 ELSE ''
			END) As ProcessType,
			IIF(FlatFileDelimiter IS NULL, 'NULL', '''' + FlatFileDelimiter + '''') AS Delimiter,
			IIF(FlatFileFormatString IS NULL, 'NULL', '''' + FlatFileFormatString + '''') AS FlatFileFormatString,
			IIF(FlatFileHasHeader IS NULL, 'NULL', '' + CAST(FlatFileHasHeader AS VARCHAR) + '') AS HasHeader,
			IIF(FlatFileHasFooter IS NULL, 'NULL', '' + CAST(FlatFileHasFooter AS VARCHAR) + '') AS HasFooter
		INTO #StagingPackage_List
		FROM dbo.StagingOwner StagingOwner 
			INNER JOIN dbo.StagingObject StagingObject 
				ON StagingOwner.StagingOwnerID = StagingObject.StagingOwnerID
			INNER JOIN dbo.Mapping Mapping 
				ON Mapping.TargetObjectID = StagingObjectID
			INNER JOIN dbo.MappingSetMapping MappingSetMapping
				ON Mapping.MappingID = MappingSetMapping.MappingID
			INNER JOIN dbo.MappingSet MappingSet
				ON MappingSetMapping.MappingSetID = MappingSet.MappingSetID
		     INNER JOIN dbo.MappingInstance MappingInstance
				ON MappingInstance.MappingSetID = MappingSet.MappingSetID
			LEFT JOIN dbo.ETLImplementationType ETLImplementationType
				ON ETLImplementationType.ETLImplementationTypeID = Mapping.DefaultETLImplementationTypeID
			LEFT JOIN dbo.Connection Connection
				ON MappingInstance.SourceConnectionID = Connection.ConnectionID
		WHERE
			Mapping.TargetTypeID = 'stag' 
			AND StagingObject.IncludeInBuild = 1
			AND Connection.SuiteName IS NOT NULL
			AND MappingInstance.IncludeInBuild = 1

		WHILE (SELECT COUNT(*) FROM #StagingPackage_List) > 0
		BEGIN
			SELECT TOP 1 
				@SuiteName = SuiteName,
				@SourceName = SourceName,
				@MappingID = MappingID,
				@StagingPackageName = StagingPackageName,
				@StagingTable = StagingTable,
				@MergeQuery = MergeQuery,
				@ProcessType = ProcessType,
				@ETLImplementationTypeID = ETLImplementationTypeID,
				@Delimiter = Delimiter,
				@FlatFileFormatString = FlatFileFormatString,
				@HasHeader = HasHeader,
				@HasFooter = HasFooter
			FROM #StagingPackage_List 
			ORDER BY  MappingID, SuiteName

			
			IF @ETLImplementationTypeID IN ('SQL_Bulkload_Staging', 'FlatFile_Bulkload_Staging')
			BEGIN
    				EXEC [dbo].[uspScriptSourceObject_Staging] @MappingID = @MappingID, @SourceQuery = @SourceQuery OUTPUT, @SourceQueryMapping = @SourceQueryMapping OUTPUT, @HeaderCheckString = @HeaderCheckString OUTPUT, @StagingPackageName = @StagingPackageName
			END



			SELECT @SQL_Print = @SQL_Print + 
'INSERT INTO [dbo].[StagingControl] ([StagingPackagePath], [StagingPackageName], [ProcessType], [SuiteName], [SourceName], [DelimiterChar], [FlatFileFormatString], [HeaderCheckString], [StagingDest], [StagingTable], [SourceQuery], [SourceQueryMapping], [MergeQuery], [HasHeader], [HasFooter])
VALUES  (''\DWStaging'', ''' + @StagingPackageName + ''', ''' + @ProcessType + ''', ''' + @SuiteName + ''', ''' + @SourceName + ''', ' + @Delimiter + ', ' + @FlatFileFormatString + ', ' 
+ (CASE WHEN COALESCE(@HeaderCheckString, '') = '' THEN 'NULL' ELSE '''' + @HeaderCheckString + '''' END) + ', ''DWStaging'', ''' + @StagingTable + ''', ' 
+ (CASE WHEN COALESCE(@SourceQuery, '"') = '"' THEN 'NULL' ELSE '''' + REPLACE(@SourceQuery,'''', '''''') + '''' END)  + ', ' 
+ (CASE WHEN COALESCE(@SourceQueryMapping, '"') = '"' THEN 'NULL' ELSE '''' + REPLACE(@SourceQueryMapping,'''', '''''') + '''' END)
+ ', ''' + @MergeQuery + ''', ' + @HasHeader + ', ' + @HasFooter + ')
GO
'					
		    SET @SourceQuery = NULL
		    SET @SourceQueryMapping = NULL
		    SET @HeaderCheckString = NULL

		--Delete processed row from tablelist
			DELETE FROM #StagingPackage_List WHERE  @SuiteName = SuiteName AND @MappingID = MappingID

		END

		--print dynamic sql
		SELECT @SQL_Print = '
USE ' + @DWReference_ModelDB + '
GO

PRINT N''Start Inserting StagingControl Records...''
GO

-----------------------------------------
--Printing InsertSQL
-----------------------------------------
'	+ COALESCE(@SQL_Print,'')  + '

PRINT N''Finished Inserting StagingControl Records...''
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