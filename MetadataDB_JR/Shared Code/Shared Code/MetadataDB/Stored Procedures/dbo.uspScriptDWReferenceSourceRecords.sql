








-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWReferenceSourceRecords]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY


		DECLARE @DWReference_ModelDB AS VARCHAR(100)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		DECLARE @SourceName AS VARCHAR(MAX) = ''
		DECLARE @SourceType AS VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
	
		SELECT Distinct SourceName, SourceType
		INTO #SourceName_List
		FROM 
		  dbo.Connection Connection
		  INNER JOIN 
		  dbo.MappingInstance MappingInstance
			 ON MappingInstance.SourceConnectionID = Connection.ConnectionID
		  LEFT JOIN dbo.ConnectionClass ConnectionClass
			 ON Connection.ConnectionClassID = ConnectionClass.ConnectionClassID
		  LEFT JOIN dbo.ConnectionClassCategory ConnectionClassCategory
			 ON ConnectionClass.ConnectionClassCategoryID = ConnectionClassCategory.ConnectionClassCategoryID
		WHERE 
		  Connection.SourceName IS NOT NULL
		  AND MappingInstance.IncludeInBuild = 1

		WHILE (SELECT COUNT(*) FROM #SourceName_List) > 0
		BEGIN
			SELECT TOP 1 
				@SourceName = SourceName,
				@SourceType = SourceType
			FROM #SourceName_List 

			SELECT @SQL_Print = @SQL_Print + 
'INSERT INTO [dbo].[SourceControl] ([SourceName], [SourceType], [AccessWindowStartMins], [AccessWindowEndMins])
VALUES  (''' + @SourceName + ''', ''' + @SourceType + ''', 1, 1440)
GO
'
					
		--Delete processed row from tablelist
			DELETE FROM #SourceName_List WHERE @SourceName = SourceName
		END

			--print dynamic sql

		SELECT @SQL_Print = '
USE ' + @DWReference_ModelDB + '
GO

PRINT N''Start Inserting SourceControl Records...''
GO

-----------------------------------------
--Printing InsertSQL
-----------------------------------------
'	+ COALESCE(@SQL_Print,'')  + '

PRINT N''Finished Inserting SourceControl Records...''
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