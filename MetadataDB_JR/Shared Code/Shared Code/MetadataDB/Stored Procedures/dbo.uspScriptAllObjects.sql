


-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc iterates through the sub stored procs to generate
-- DWData and DWExtract Objects and creates an overall script
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptAllObjects]
(
	@Environment AS VARCHAR(100) = 'Model'
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

	BEGIN TRY

		DECLARE @ErrorCount AS INT
		EXEC @ErrorCount = [dbo].[uspAuditReport] 1
		IF @ErrorCount > 0 
		  RAISERROR (
			 'Errors Encountered when auditing Metadata Model. Fix the errors and then try re-scripting', -- Message text.
               16, -- Severity.
               1 -- State.
               );

		DECLARE @SQLALL AS VARCHAR(MAX)
		DECLARE @DWData_ModelDB AS VARCHAR(100)
		DECLARE @DWData_TargetDB AS VARCHAR(100)
		DECLARE @DWExtract_ModelDB AS VARCHAR(100)
		DECLARE @DWData_Size_DataFile AS VARCHAR(100)
		DECLARE @DWData_Size_LogFile AS VARCHAR(100)
		DECLARE @DWExtract_Size_DataFile AS VARCHAR(100)
		DECLARE @DWExtract_Size_LogFile AS VARCHAR(100)
		DECLARE @DWStaging_ModelDB AS VARCHAR(100)
		DECLARE @DWStaging_Size_DataFile AS VARCHAR(100)
		DECLARE @DWStaging_Size_LogFile AS VARCHAR(100)

		DECLARE @DataMartID AS VARCHAR(40)
		DECLARE @DataMartIncrement AS INT = 0

		--Retrieve database names from the parameter table
		SET @DWData_TargetDB = (SELECT dbo.fnGetParameterValue('DWData_TargetDB') )

		--Depending on the @environment variable retrieve the Database Names
		IF (@Environment = 'Model')
		BEGIN
			SET @DWData_ModelDB = (SELECT dbo.fnGetParameterValue('DWData_ModelDB') )
			SET @DWExtract_ModelDB = (SELECT dbo.fnGetParameterValue('DWExtract_ModelDB') )	
			SET @DWStaging_ModelDB = (SELECT dbo.fnGetParameterValue('DWStaging_ModelDB') )
		END
		ELSE IF (@Environment IN ('DEV', 'UAT', 'PROD'))
		BEGIN
			SET @DWData_ModelDB = (SELECT dbo.fnGetParameterValue('DWData_ActualDB') )
			SET @DWExtract_ModelDB = (SELECT dbo.fnGetParameterValue('DWExtract_ActualDB') )	
			SET @DWStaging_ModelDB = (SELECT dbo.fnGetParameterValue('DWStaging_ActualDB') )
		END


		--Depending on the @environment variable retrieve the Database Sizing
		IF (@Environment = 'Model')
		BEGIN
			SET @DWData_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWData_Size_DataFile_Model') )
			SET @DWData_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWData_Size_LogFile_Model') )			
			SET @DWExtract_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_DataFile_Model') )
			SET @DWExtract_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_LogFile_Model') )	
			SET @DWStaging_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_DataFile_Model') )
			SET @DWStaging_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_LogFile_Model') )	
		END
		ELSE IF (@Environment = 'DEV')
		BEGIN
			SET @DWData_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWData_Size_DataFile_DEV') )
			SET @DWData_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWData_Size_LogFile_DEV') )			
			SET @DWExtract_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_DataFile_DEV') )
			SET @DWExtract_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_LogFile_DEV') )			
			SET @DWStaging_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_DataFile_DEV') )
			SET @DWStaging_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_LogFile_DEV') )	
		END
		ELSE IF (@Environment = 'UAT')
		BEGIN
			SET @DWData_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWData_Size_DataFile_UAT') )
			SET @DWData_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWData_Size_LogFile_UAT') )			
			SET @DWExtract_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_DataFile_UAT') )
			SET @DWExtract_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_LogFile_UAT') )			
			SET @DWStaging_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_DataFile_UAT') )
			SET @DWStaging_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_LogFile_UAT') )	
		END
		ELSE IF (@Environment = 'PROD')
		BEGIN
			SET @DWData_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWData_Size_DataFile_PROD') )
			SET @DWData_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWData_Size_LogFile_PROD') )			
			SET @DWExtract_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_DataFile_PROD') )
			SET @DWExtract_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWExtract_Size_LogFile_PROD') )			
			SET @DWStaging_Size_DataFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_DataFile_PROD') )
			SET @DWStaging_Size_LogFile = (SELECT dbo.fnGetParameterValue('DWStaging_Size_LogFile_PROD') )	
		END


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
			/* select the rows based on ExtractJobID into temporary table */	


		SELECT @SQLALL = '

SET NOCOUNT ON
GO

USE Master
GO

PRINT N''Dropping Database ' + @DWData_ModelDB + '...''
GO

IF (DB_ID(N''' + @DWData_ModelDB + ''') IS NOT NULL) 
BEGIN
	ALTER DATABASE [' + @DWData_ModelDB + ']
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [' + @DWData_ModelDB + '];
END

GO

PRINT N''Dropping Database ' + @DWExtract_ModelDB + '...''
GO

IF (DB_ID(N''' + @DWExtract_ModelDB + ''') IS NOT NULL) 
BEGIN
	ALTER DATABASE [' + @DWExtract_ModelDB + ']
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [' + @DWExtract_ModelDB + '];
END

GO

PRINT N''Dropping Database ' + @DWStaging_ModelDB + '...''
GO

IF (DB_ID(N''' + @DWStaging_ModelDB + ''') IS NOT NULL) 
BEGIN
	ALTER DATABASE [' + @DWStaging_ModelDB + ']
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [' + @DWStaging_ModelDB + '];
END

GO

PRINT N''Creating Database ' + @DWData_ModelDB + '...''
GO
PRINT N''Creating Database ' + @DWExtract_ModelDB + '...''
GO
PRINT N''Creating Database ' + @DWStaging_ModelDB + '...''
GO

--This section is used to get the correct logical and physcial file extensions for the CREATE database statements
	IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = ''zzDefaultPathDB'')   

	BEGIN  
		DROP DATABASE zzDefaultPathDB
	END

	CREATE DATABASE zzDefaultPathDB;

	DECLARE @Data_Path VARCHAR(MAX), 
			@Log_Path VARCHAR(MAX),
			@Default_Data_Path VARCHAR(MAX) = '''',   
			@Default_Log_Path VARCHAR(MAX) = '''',
			@Default_Data_PExt VARCHAR(MAX) = '''',   
			@Default_Data_LExt VARCHAR(MAX) = '''',   
			@Default_Log_PExt VARCHAR(MAX) = '''',
			@Default_Log_LExt VARCHAR(MAX) = '''';


		SELECT 
			@Data_Path =  RTRIM(physical_name),
			@Default_Data_Path =  RTRIM((LEFT(physical_name,LEN(physical_name)-CHARINDEX(''\'',REVERSE(physical_name))+1))), 
			@Default_Data_LExt = RTRIM(REPLACE(mf.name, ''zzDefaultPathDB'', ''''))
		FROM sys.master_files mf   
			INNER JOIN sys.[databases] d   
			ON mf.[database_id] = d.[database_id]   
		WHERE d.[name] = ''zzDefaultPathDB'' AND type = 0;

		SELECT 
			@Log_Path =  RTRIM(physical_name),
			@Default_Log_Path =  RTRIM((LEFT(physical_name,LEN(physical_name)-CHARINDEX(''\'',REVERSE(physical_name))+1))), 
			@Default_Log_LExt = RTRIM(REPLACE(mf.name, ''zzDefaultPathDB'', ''''))
		FROM sys.master_files mf   
		INNER JOIN sys.[databases] d   
		ON mf.[database_id] = d.[database_id]   
		WHERE d.[name] = ''zzDefaultPathDB'' AND type = 1;

	--Clean up. Drop de temp database 
	IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = ''zzDefaultPathDB'')   
	BEGIN  
		DROP DATABASE zzDefaultPathDB   
	END;

	SELECT @Default_Data_PExt = REPLACE(REPLACE(@Data_Path, @Default_Data_Path, ''''), ''zzDefaultPathDB'', '''')
	SELECT @Default_Log_PExt = REPLACE(REPLACE(@Log_Path, @Default_Log_Path, ''''), ''zzDefaultPathDB'', '''')
--End of Section for Database Sizing


DECLARE @SQLCreateDatabases AS VARCHAR(MAX)
SELECT @SQLCreateDatabases = ''


CREATE DATABASE ' + @DWData_ModelDB + '
ON 
( NAME = ' + @DWData_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWData_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWData_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWData_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWData_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWData_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWData_ModelDB + '] SET RECOVERY SIMPLE 



CREATE DATABASE ' + @DWExtract_ModelDB + '
ON 
( NAME = ' + @DWExtract_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWExtract_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWExtract_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWExtract_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWExtract_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWExtract_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWExtract_ModelDB + '] SET RECOVERY SIMPLE 



CREATE DATABASE ' + @DWStaging_ModelDB + '
ON 
( NAME = ' + @DWStaging_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWStaging_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWStaging_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWStaging_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWStaging_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWStaging_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWStaging_ModelDB + '] SET RECOVERY SIMPLE 


''

exec (@SQLCreateDatabases)
GO

'


		PRINT @SQLALL
		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWData_ModelDB, 'DWData', 0
		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWExtract_ModelDB, 'DWExtract', 0
		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWStaging_ModelDB, 'DWStaging', 0


		exec [dbo].[uspScriptDWStagingObjects] @Environment, @DWStaging_ModelDB
		exec [dbo].[uspScriptDWBaseObjects] @Environment, @DWData_ModelDB
		exec [dbo].[uspScriptDWExtractObjects] @Environment, @DWExtract_ModelDB, @DWData_TargetDB
		exec [dbo].[uspScriptDWDeliveryProcs] @Environment, @DWExtract_ModelDB
		exec [dbo].[uspScriptDWLogicalLayer] @Environment, @DWData_ModelDB
		
		IF OBJECT_ID('tempdb..#DataMarts') IS NOT NULL
			DROP TABLE #DataMarts
		
		SELECT DataMartID
		INTO #DataMarts
		FROM [dbo].[DataMart]
		WHERE IncludeInBuild = 1

		WHILE (SELECT COUNT(*) FROM #DataMarts) > 0
		BEGIN
			SELECT TOP 1 @DataMartID = DataMartID FROM #DataMarts
			
			exec [dbo].[uspScriptDWDatamartLayer] @Environment, @DataMartID, @DataMartIncrement, @DWData_ModelDB
			
			DELETE FROM #DataMarts WHERE DataMartID = @DataMartID
			SELECT @DataMartIncrement = @DataMartIncrement + 1

		END

		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWData_ModelDB, 'DWData', 1
		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWExtract_ModelDB, 'DWExtract', 1
		exec [dbo].[uspScriptDatabaseDeploymentScript] @DWStaging_ModelDB, 'DWStaging', 1


		exec [dbo].[uspScriptDWReferenceLayer]


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