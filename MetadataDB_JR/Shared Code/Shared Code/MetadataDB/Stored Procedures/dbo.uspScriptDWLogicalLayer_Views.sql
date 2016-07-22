



-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWLogicalLayer_Views]
	@Environment AS VARCHAR(100) = 'Model',
	@MappingID VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY


		--Declare Script Variables
		DECLARE 
			@Sql_ViewName AS VARCHAR(MAX) = '',
			@Sql_View AS VARCHAR(MAX) = '',
			@Sql_ElementMapping AS VARCHAR(MAX) = '',
			@Sql_DW_ExtendedProps AS VARCHAR(MAX)  = ''


		--Declare Schema Level Variables
		DECLARE	
			@DWLayerAbbreviation AS VARCHAR(40) = ''

		--Declare Mapping Level Variables
		DECLARE 
			@DWObjectName AS VARCHAR(100) = '',
			@DWObjectDesc AS VARCHAR(MAX) = '',
			@DWObjectGroupAbbreviation AS VARCHAR(40) = '',
			@DWObjectLoadLogic AS VARCHAR(40) = '',
			@SourceObjectLogic AS VARCHAR(MAX) 

		--Declare Element Level Variables
		DECLARE 
			@DWElementID AS VARCHAR(100) = '',
			@DWElementDesc AS VARCHAR(MAX) = '',
			@SourceElementLogic AS VARCHAR(MAX) = '',	
			@DWElementName AS VARCHAR(100) = '',
			@ElementCount AS INT = 0

		SELECT
			@MappingID = Mapping.MappingID,
			@DWObjectName = DWObject.DWObjectName,
			@DWObjectDesc = REPLACE(COALESCE(DWObject.DWObjectDesc, ''), '''', ''''''), 
			@DWLayerAbbreviation = DWLayer.DWLayerAbbreviation,
			@DWObjectLoadLogic = DWObjectType.DWObjectLoadLogic,
			@DWObjectGroupAbbreviation = DWObjectType.DWObjectGroupAbbreviation,
			@SourceObjectLogic = Mapping.SourceObjectLogic
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
			INNER JOIN dbo.DWObjectType
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer
				ON DWObject.DWLayerID = DWLayer.DWLayerID 
		WHERE
			Mapping.MappingID = @MappingID

		SELECT @Sql_DW_ExtendedProps = 
'
EXEC sys.sp_addextendedproperty 
	@name = N''MS_Description'', 
	@value = N''[CREATED FROM MetadataDB] ' + @DWObjectDesc + ''', 
	@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
	@level1type = N''VIEW'',  @level1name = ''' + @DWObjectGroupAbbreviation + @DWObjectName + ''';
GO

'

			if object_id ('tempdb..#MappingElement' ) is not null
			   DROP TABLE #MappingElement
			
			SELECT 		
				Row_Number() OVER (ORDER BY COALESCE(DWElement.BusinessKeyOrder, 999), (CASE WHEN DWElementName IN ('LoadTime', 'LastUpdateTime') THEN 'ZZZ' + DWElementName ELSE DWElementName END)) AS RowID,
				DWElement.DWElementID,
				DWElement.DWElementDesc,
				MappingElement.SourceElementLogic,
				DWElement.DWElementName
			INTO #MappingElement
			FROM 
				dbo.MappingElement MappingElement
				INNER JOIN dbo.DWElement DWElement
					ON MappingElement.TargetElementID = DWElement.DWElementID
			WHERE 
				MappingElement.MappingID = @MappingID

			WHILE (SELECT COUNT(*) FROM #MappingElement) > 0
			BEGIN
				SELECT TOP 1
					@DWElementID = DWElementID,
					@DWElementDesc = REPLACE(COALESCE(DWElementDesc, ''), '''', ''''''), 
					@SourceElementLogic = SourceElementLogic,
					@DWElementName = DWElementName
				FROM #MappingElement
				ORDER BY RowID

				SELECT @ElementCount = @ElementCount + 1

			
				SELECT @Sql_ElementMapping = @Sql_ElementMapping + '
	' + (CASE WHEN @ElementCount = 1 THEN '' ELSE ',' END) + @SourceElementLogic + ' AS ' + @DWElementName


				--Add DWElement Level MS_Description Extended Property
				SELECT @Sql_DW_ExtendedProps = @Sql_DW_ExtendedProps + 
'
		EXEC sys.sp_addextendedproperty 
			@name = N''MS_Description'', 
			@value = N''[CREATED FROM MetadataDB] ' + @DWElementDesc + ''', 
			@level0type = N''SCHEMA'', @level0name = ''' + @DWLayerAbbreviation + ''', 
			@level1type = N''VIEW'',  @level1name = ''' + @DWObjectGroupAbbreviation + @DWObjectName + ''',
			@level2type = N''COLUMN'', @level2name = ''' + @DWElementName + ''';		
		GO
'

				DELETE FROM #MappingElement WHERE DWElementID = @DWElementID
			END

			SELECT @Sql_ViewName = @DWLayerAbbreviation + '.' + @DWObjectGroupAbbreviation + @DWObjectName

			SELECT @OutputSQL = '
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
FROM ' + @SourceObjectLogic + '
GO
' + @Sql_DW_ExtendedProps + '


'

		

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