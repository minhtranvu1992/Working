



-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWDatamartLayer]
(
	@Environment AS VARCHAR(100) = 'Model',
	@DataMartID VARCHAR(40) = '',
	@DataMartIncrement INT = 0,
	@DWData_ModelDB AS VARCHAR(100)
)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY


		--Declare Script Variables
		DECLARE @Sql_ALL AS VARCHAR(MAX) = ''

		DECLARE @Sql_Header AS VARCHAR(MAX) = '',
				@Sql_ViewName AS VARCHAR(MAX) = '',
				@Sql_Views AS VARCHAR(MAX) = '',
				@Sql_View AS VARCHAR(MAX) = '',
				@Sql_ElementMapping AS VARCHAR(MAX) = '',
				@Sql_DW_ExtendedProps AS VARCHAR(MAX)  = ''

		--Declare Schema Level Variables
		DECLARE	@DataMartSchemaAbbreviation AS VARCHAR(40) = ''

		--Declare DWObject Level Variables
		DECLARE @DWObjectID AS VARCHAR(100) = '',
				@DWObjectDesc AS VARCHAR(MAX) = '',
				@DWObjectName AS VARCHAR(100) = '',
				@DWObjectGroupAbbreviation AS VARCHAR(40) = '',
				@DWLayerAbbreviation AS VARCHAR(40) = ''

		--Declare Element Level Variables
		DECLARE @DWElementID AS VARCHAR(100) = '',
				@DWElementDesc AS VARCHAR(MAX) = '',
				@DWElementName AS VARCHAR(100) = '',
				@ElementCount AS INT = 0

		SELECT	@DataMartSchemaAbbreviation = (SELECT DataMartSchemaAbbreviation FROM dbo.DataMart DataMart WHERE DataMart.DataMartID =@DataMartID)

		SELECT @Sql_Header = '
PRINT N''Creating Schema ' + @DataMartSchemaAbbreviation + '...''
GO

		
IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @DataMartSchemaAbbreviation + ''')
	execute(''CREATE SCHEMA ' + @DataMartSchemaAbbreviation + ' AUTHORIZATION dbo'')
GO

PRINT N''Creating Database Role ' + @DataMartID + '_read...''
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N''' + @DataMartID + '_read'' AND type = ''R'')
BEGIN
	CREATE ROLE [' + @DataMartID + '_read]	
	
END
GO

GRANT SELECT ON SCHEMA::[' + @DataMartSchemaAbbreviation + '] TO [' + @DataMartID + '_read]
GO
	
GRANT VIEW DEFINITION ON SCHEMA::[' + @DataMartSchemaAbbreviation + '] TO [' + @DataMartID + '_read]
GO

'


		if object_id ('tempdb..#DataMartObjects' ) is not null
		   DROP TABLE #DataMartObjects

		SELECT DISTINCT
			DWObject.DWObjectID,
			DWObject.DWObjectDesc,
			DWObject.DWObjectName,
			DWObjectType.DWObjectGroupAbbreviation,
			DWLayer.DWLayerAbbreviation
		INTO #DataMartObjects
		FROM 
			dbo.DataMart DataMart
			INNER JOIN dbo.DataMartDWElement DataMartDWElement ON DataMart.DataMartID = DataMartDWElement.DataMartID
			INNER JOIN dbo.DWElement DWElement ON DataMartDWElement.DWElementID = DWElement.DWElementID
			INNER JOIN dbo.DWObject DWObject ON DWElement.DWObjectID = DWObject.DWObjectID
			INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
		WHERE 
			DataMart.DataMartID = @DataMartID
			AND DWObject.IncludeInBuild = 1

		WHILE (SELECT COUNT(*) FROM #DataMartObjects) > 0
		BEGIN
			SELECT TOP 1
				@DWObjectID = DWObjectID,
				@DWObjectDesc = REPLACE(COALESCE(DWObjectDesc, ''), '''', ''''''), 
				@DWObjectName = DWObjectName,
				@DWObjectGroupAbbreviation = DWObjectGroupAbbreviation,
				@DWLayerAbbreviation	 = DWLayerAbbreviation
			FROM
				#DataMartObjects	

			if object_id ('tempdb..#MappingElement' ) is not null
			   DROP TABLE #MappingElement
			
			SELECT 		
				Row_Number() OVER (ORDER BY COALESCE(DWElement.BusinessKeyOrder, 999), (CASE WHEN DWElementName IN ('LoadTime', 'LastUpdateTime') THEN 'ZZZ' + DWElementName ELSE DWElementName END)) AS RowID,
				DWElement.DWElementID,
				DWElement.DWElementDesc,
				DWElement.DWElementName
			INTO #MappingElement
			FROM 
				dbo.DataMart DataMart
				INNER JOIN dbo.DataMartDWElement DataMartDWElement ON DataMart.DataMartID = DataMartDWElement.DataMartID
				INNER JOIN dbo.DWElement DWElement ON DataMartDWElement.DWElementID = DWElement.DWElementID
				INNER JOIN dbo.DWObject DWObject ON DWElement.DWObjectID = DWObject.DWObjectID
				INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
				INNER JOIN dbo.DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			WHERE 
				DataMart.DataMartID = @DataMartID AND DWObject.DWObjectID = @DWObjectID

			SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
EXEC sys.sp_addextendedproperty 
	@name = N''MS_Description'', 
	@value = N''[CREATED FROM MetadataDB] ' + @DWObjectDesc + ''', 
	@level0type = N''SCHEMA'', @level0name = ''' + @DataMartSchemaAbbreviation + ''', 
	@level1type = N''VIEW'',  @level1name = ''' + @DWObjectGroupAbbreviation + @DWObjectName + ''';
GO

'

			WHILE (SELECT COUNT(*) FROM #MappingElement) > 0
			BEGIN
				SELECT TOP 1
					@DWElementID = DWElementID,
					@DWElementDesc = REPLACE(COALESCE(DWElementDesc, ''), '''', ''''''), 
					@DWElementName = DWElementName
				FROM #MappingElement
				ORDER BY RowID

				SELECT @ElementCount = @ElementCount + 1

			
				SELECT @Sql_ElementMapping = @Sql_ElementMapping + '
	'  + 
				(CASE 
					WHEN @ElementCount = 1 THEN '' 
					ELSE ',' 
				END) + @DWElementName

				--Add DWElement Level MS_Description Extended Property
				SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWElementDesc + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DataMartSchemaAbbreviation + ''', 
			@level1type = N''VIEW'',  @level1name = ''' + @DWObjectGroupAbbreviation + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''' + @DWElementName + ''';		
		GO
'

				DELETE FROM #MappingElement WHERE DWElementID = @DWElementID
			END

			SELECT @Sql_ViewName = @DataMartSchemaAbbreviation + '.' + @DWObjectGroupAbbreviation + @DWObjectName

			SELECT @Sql_View = '
PRINT N''Dropping View ' + @Sql_ViewName + '...''
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(''' + @Sql_ViewName + '''))
	DROP VIEW ' + @Sql_ViewName + '
GO

PRINT N''Creating View ' + @Sql_ViewName + '...''
GO

-- ====================================================================================
-- *** CREATED FROM Metadata, TO CHANGE UPDATE Metadata in Solution AND RECREATE ***
-- Author:		Metadata
-- Description: ' + @Sql_ViewName + '  
--				
-- ====================================================================================
CREATE VIEW ' + @Sql_ViewName + ' AS 
SELECT' + @Sql_ElementMapping + '
FROM ' + @DWLayerAbbreviation + '.' + @DWObjectGroupAbbreviation + @DWObjectName + '
GO

'
		
			SELECT @Sql_Views = @Sql_Views + @Sql_View

			SELECT @Sql_ElementMapping = ''
			SELECT @ElementCount = 0
			SELECT @Sql_View = ''

			DELETE FROM #DataMartObjects WHERE DWObjectID = @DWObjectID
		END

		SELECT @Sql_ALL = '
USE ' + @DWData_ModelDB + '
GO

-----------------------------------------
--Printing Schemas, Roles, Permissions
-----------------------------------------
'	+ COALESCE(@Sql_Header,'') + '
-----------------------------------------
--Printing Datamart views
-----------------------------------------
'	+ COALESCE(@Sql_Views,'') + '
-----------------------------------------
--Printing Datamart views
-----------------------------------------
'	+ COALESCE(@Sql_DW_ExtendedProps,'')


		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Logical_Layer'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT (5 + @DataMartIncrement), ('Datamart_Layer_' + @DataMartID), @Sql_ALL
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