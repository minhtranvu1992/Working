

-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDatabaseDeploymentScript]
(
     @DatabaseName AS VARCHAR(100),
	@DatabaseLayer AS VARCHAR(100),
	@IsPostDeployScript AS BIT
	--,
	--@OutputSQL VARCHAR(MAX) OUTPUT
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

    BEGIN TRY

	   --TestingValues-Start
	   --DECLARE @DatabaseLayer AS VARCHAR(100) = 'DWData'
	   --DECLARE @IsPostDeployScript AS BIT = 1
	   --DECLARE @OutputSQL VARCHAR(MAX)
	   --DECLARE @DatabaseName VARCHAR(MAX)
	   --TestingValues-End

	   DECLARE @ScriptSQL AS VARCHAR(MAX)	  
	   DECLARE @ScriptOrder AS INT 
	   DECLARE @ScriptSQLALL AS VARCHAR(MAX)
	   DECLARE @PrePost AS VARCHAR(MAX)

	   SELECT @PrePost = (SELECT CASE WHEN @IsPostDeployScript = 0 THEN 'Pre' ELSE 'Post' END)

	   SELECT 
		  ScriptOrder
		  ,ScriptSQL
	   INTO #BuildScripts
	   FROM dbo.BuildScripts
	   WHERE DatabaseLayer = @DatabaseLayer
		  AND IsPostDeployScript = @IsPostDeployScript
		  AND IncludeInBuild = 1

	   IF (SELECT COUNT(*) FROM #BuildScripts) > 0
		  SELECT @ScriptSQLALL = '
PRINT N''Creating ' + @PrePost + '-Build Objects for ' + @DatabaseName + '...''
GO

USE ' + @DatabaseName + '
GO
'
	   WHILE (SELECT COUNT(*) FROM #BuildScripts) > 0
	   BEGIN
		  SELECT TOP 1
			 @ScriptOrder = ScriptOrder,
			 @ScriptSQL = ScriptSQL
		  FROM 
			 #BuildScripts
		  ORDER BY 
			 ScriptOrder ASC

		  SET @ScriptSQLALL = @ScriptSQLALL + '
--ScriptOrder: ' + CAST(@ScriptOrder AS VARCHAR) + '
' + @ScriptSQL + '
GO

'
		  DELETE FROM   #BuildScripts WHERE ScriptOrder = @ScriptOrder  
	   END

	   exec [dbo].[udpLongPrint] @ScriptSQLALL

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