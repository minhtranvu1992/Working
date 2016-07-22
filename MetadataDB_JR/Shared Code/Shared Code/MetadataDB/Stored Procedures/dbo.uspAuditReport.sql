






CREATE PROCEDURE [dbo].[uspAuditReport]
    @IncludeInBuildObjectsOnly BIT = 1
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

	BEGIN TRY

		DECLARE @ErrorCount AS INT

		/* drop the temporary table if exists */
		IF OBJECT_ID('tempdb..#ModelValidationTable') IS NOT NULL
			DROP TABLE #ModelValidationTable

		CREATE TABLE #ModelValidationTable
		(
		  ObjectType NVARCHAR(100) NOT NULL,
		  ParentObjectID NVARCHAR(100) NOT NULL,
		  ObjectID NVARCHAR(100) NOT NULL, 
		  Severity NVARCHAR(40) NOT NULL,
		  Violation NVARCHAR(200) NOT NULL,
		  Mitigation NVARCHAR(MAX) NULL,
		  IncludeInBuild BIT NULL
		)

		CREATE UNIQUE CLUSTERED INDEX UIX_ScriptsTable ON #ModelValidationTable
		(ParentObjectID, ObjectID ASC, Violation ASC)

		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWObject_NoElements]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWObject_NoMapping]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Mapping_NotMemberOfMappingSet]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Mapping_Issues]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_MissingMappingElement]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_MappingElement_Orphaned]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_NotUsedinDatamart]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Datamart_OrphanedElements]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_LookupObjectHasIncorrectLayer]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Mapping_MappingSetContainsMappingsTargetingMultipleLayerTypes]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_NameMismatchWithLookupEntity]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_MultipleSnapshotProcessSeperator]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_DWElement_SnapshotProcessSeperatorNotRequired]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Object_BusinessKeyMissing]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_Element_BusinessKeyOrder]
		INSERT INTO #ModelValidationTable SELECT * FROM [dbo].[vAudit_All_Identifiers]

		IF @IncludeInBuildObjectsOnly = 1 
		BEGIN
		  SELECT * FROM #ModelValidationTable WHERE IncludeInBuild = 1
		  ORDER BY (CASE Severity WHEN 'Error' THEN 1 WHEN 'Warning' THEN 2 ELSE 99 END), ObjectType, ParentObjectID, ObjectID
		  SELECT @ErrorCount = COUNT(*) FROM #ModelValidationTable WHERE IncludeInBuild = 1 AND Severity = 'Error'
		END
		ELSE
		BEGIN 
		  SELECT * FROM #ModelValidationTable 
		  ORDER BY (CASE Severity WHEN 'Error' THEN 1 WHEN 'Warning' THEN 2 ELSE 99 END), ObjectType, ParentObjectID, ObjectID
		  SELECT @ErrorCount = COUNT(*) FROM #ModelValidationTable WHERE Severity = 'Error'
		END
	     
		Return @ErrorCount

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