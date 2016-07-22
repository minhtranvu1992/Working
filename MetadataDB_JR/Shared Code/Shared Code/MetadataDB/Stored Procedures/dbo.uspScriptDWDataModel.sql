




-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the DW Tables
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWDataModel]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @DWData_DataModelDB AS VARCHAR(100)
		DECLARE @DataMartID AS VARCHAR(40)
		DECLARE @DataMartIncrement AS INT = 0

		SET @DWData_DataModelDB = (SELECT dbo.fnGetParameterValue('DWData_DataModelDB') )

		DECLARE @SQLALL AS VARCHAR(MAX)

		/* drop the temporary table if exists */
		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
			DROP TABLE ##ScriptsTable

		CREATE TABLE ##ScriptsTable
		(
		  ScriptOrder INT NOT NULL,
		  ScriptType VARCHAR(40) NOT NULL, 
		  Script VARCHAR(MAX) NOT NULL
		)

		CREATE UNIQUE CLUSTERED INDEX UIX_ScriptsTable ON ##ScriptsTable
		( ScriptOrder ASC)


		--Drop and recreate database for data model
		SELECT @SQLALL = '
USE Master
GO

IF (DB_ID(N''' + @DWData_DataModelDB + ''') IS NOT NULL) 
BEGIN
	ALTER DATABASE [' + @DWData_DataModelDB + ']
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [' + @DWData_DataModelDB + '];
END

GO
PRINT N''Creating ' + @DWData_DataModelDB + '...''
GO
CREATE DATABASE [' + @DWData_DataModelDB + '] 
GO
'

		exec [dbo].[udpLongPrint] @SQLALL

		exec [dbo].[uspScriptDWBaseObjects] 'Model', @DWData_DataModelDB
		exec [dbo].[uspScriptLogicalModel] 'Model', @DWData_DataModelDB

		IF OBJECT_ID('tempdb..#DataMarts') IS NOT NULL
			DROP TABLE #DataMarts
		
		SELECT DataMartID
		INTO #DataMarts
		FROM [dbo].[DataMart]
		WHERE IncludeInBuild = 1

		WHILE (SELECT COUNT(*) FROM #DataMarts) > 0
		BEGIN
			SELECT TOP 1 @DataMartID = DataMartID FROM #DataMarts
			
			exec [dbo].[uspScriptDWDatamartLayer] 'Model', @DataMartID, @DataMartIncrement, @DWData_DataModelDB
			
			DELETE FROM #DataMarts WHERE DataMartID = @DataMartID
			SELECT @DataMartIncrement = @DataMartIncrement + 1

		END
		
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