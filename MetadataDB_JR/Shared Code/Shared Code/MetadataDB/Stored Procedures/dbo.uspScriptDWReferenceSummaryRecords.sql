







-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWReferenceSummaryRecords]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @DWReference_ModelDB AS VARCHAR(100)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		DECLARE @SummaryPackageName AS VARCHAR(MAX) = ''
		DECLARE @SummaryTableName AS VARCHAR(MAX) = ''
		DECLARE @SourceQuery AS VARCHAR(MAX) = ''
		DECLARE @ExecutionOrder AS VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		
		SELECT 
			('dbo.uspDeliver_' + DWObjectType.DWObjectGroupAbbreviation + DWObject.DWObjectName) AS SummaryPackageName, 
			(DWLayer.DWLayerID + '.' + DWObjectType.DWObjectGroupAbbreviation + DWObject.DWObjectName) AS SummaryTableName, 
			CAST(MappingSetMapping.BuildOrder AS VARCHAR) AS ExecutionOrder
		INTO #SummaryPackage_List
		FROM dbo.DWLayer DWLayer 
			INNER JOIN dbo.DWObject DWObject 
				ON DWLayer.DWLayerID = DWObject.DWLayerID
			INNER JOIN dbo.DWObjectType DWObjectType
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.Mapping Mapping 
				ON Mapping.TargetObjectID = DWObjectID
			INNER JOIN dbo.MappingSetMapping MappingSetMapping
				ON Mapping.MappingID = MappingSetMapping.MappingID
		WHERE 
			DWLayerType = 'Logical'
			AND DWObject.IncludeInBuild = 1
			AND DWObject.DWObjectBuildTypeID = 'Table'


		WHILE (SELECT COUNT(*) FROM #SummaryPackage_List) > 0
		BEGIN
			SELECT TOP 1 
				@SummaryPackageName = SummaryPackageName,
				@SummaryTableName = SummaryTableName,
				@ExecutionOrder = ExecutionOrder
			FROM #SummaryPackage_List 
			ORDER BY SummaryPackageName

			SELECT @SourceQuery = '"EXEC ' + @SummaryPackageName + ' @DeliveryJobID = " +  (DT_WSTR, 10)@[User::DeliveryJobID] + ", @StartTime = ''''" + @[User::LastExecutionTime] + "''''"'

			SELECT @SQL_Print = @SQL_Print + 
'INSERT INTO [dbo].[SummaryControl] ([SummaryPackageName], [SummaryTableName], [ScheduleType], [SourceQuery], [Type], [SourceControlID], [LastSummaryJobID], [ExecutionOrder])
VALUES  (''' + @SummaryPackageName + '''  ,''' + @SummaryTableName + '''  ,''Daily''  ,''' + @SourceQuery + '''  ,''SP''  ,1,1,' + @ExecutionOrder + ')
GO
'					
		--Delete processed row from tablelist
			DELETE FROM #SummaryPackage_List WHERE  @SummaryPackageName = SummaryPackageName

		END

		--print dynamic sql
		SELECT @SQL_Print = '
USE ' + @DWReference_ModelDB + '
GO

PRINT N''Start Inserting SummaryControl Records...''
GO

-----------------------------------------
--Printing InsertSQL
-----------------------------------------
'	+ COALESCE(@SQL_Print,'')  + '

PRINT N''Finished Inserting SummaryControl Records...''
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