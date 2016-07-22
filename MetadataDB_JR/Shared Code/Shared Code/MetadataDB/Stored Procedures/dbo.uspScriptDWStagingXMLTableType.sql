


-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWStagingXMLTableType]
	@StagingObjectID VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

  	    DECLARE @SQL_TableType AS VARCHAR(MAX) = ''

	    DECLARE @Sql_PrimaryKey AS VARCHAR(MAX)

	    --Declare feed variables
	    DECLARE @StagingObjectName AS VARCHAR(MAX)
	    DECLARE @StagingOwnerID AS VARCHAR(MAX)
	    DECLARE @StagingObjectDesc AS VARCHAR(MAX)

	    DECLARE @FullStagingObjectName AS VARCHAR(MAX)
	    DECLARE @StagingJobIDDataType AS VARCHAR(MAX)

	    --Declare Attribute variables
	    DECLARE @StagingElementName AS VARCHAR(MAX)
	    DECLARE @StagingElementOrder AS INT
	    DECLARE @StagingElementDesc AS VARCHAR(MAX)
	    DECLARE @BusinessKeyOrder AS INT
	    DECLARE @DataType AS VARCHAR(MAX)
	    DECLARE @AttributeNull AS VARCHAR(MAX)


		SELECT TOP 1 
		  @StagingObjectName = StagingObjectName,
		  @StagingOwnerID = StagingOwnerID,
		  @StagingObjectDesc = StagingObjectDesc
		FROM  dbo.StagingObject StagingObject
		WHERE @StagingObjectID = StagingObjectID


		SELECT @FullStagingObjectName = @StagingObjectName

		-- Table Header level logic
		SELECT @SQL_TableType = '
PRINT N''Dropping Table Type ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Table...''
GO

IF  EXISTS (SELECT * FROM sys.types types INNER JOIN sys.schemas schemas ON types.schema_id = schemas.schema_id WHERE types.name = N''' + @FullStagingObjectName + '_Table'' AND schemas.name = N''' + @StagingOwnerID + ''' AND is_user_defined = 1)
    DROP TYPE ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Table
GO

PRINT N''Creating Table Type ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Table...''
GO

CREATE TYPE ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Table AS TABLE(
   MessageID uniqueidentifier NOT NULL
'

	     --POPULATE #StagingElement
	     if object_id ('tempdb..#StagingElement' ) is not null
		   DROP TABLE #StagingElement

		SELECT 
		  StagingElementName, StagingElementOrder, BusinessKeyOrder, DataType
	     INTO #StagingElement
		FROM dbo.StagingElement StagingElement
		  LEFT JOIN dbo.DomainDataType DomainDataType ON StagingElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
		WHERE StagingObjectID = @StagingObjectID

		WHILE (SELECT COUNT(*) FROM #StagingElement) > 0
		BEGIN
			SELECT TOP 1 @StagingElementName = StagingElementName,
				@StagingElementOrder = StagingElementOrder,
				@BusinessKeyOrder = COALESCE(BusinessKeyOrder,0),
				@DataType = DataType 
			FROM #StagingElement
    			ORDER BY COALESCE(BusinessKeyOrder, 999), StagingElementOrder			

			SELECT @AttributeNull = ' NULL' 
		
			IF @BusinessKeyOrder = 1
			 BEGIN
				    SELECT @Sql_PrimaryKey = @StagingElementName + ' ASC'
				    SELECT @AttributeNull = ' NOT NULL'
						
			 END
			ELSE IF (@BusinessKeyOrder >= 1)
			 BEGIN
				    SELECT @Sql_PrimaryKey = @Sql_PrimaryKey + ', ' + @StagingElementName + ' ASC'
				    SELECT @AttributeNull = ' NOT NULL'					
			 END

			SELECT @SQL_TableType = @SQL_TableType + '   ,' + @StagingElementName + ' ' + @DataType + @AttributeNull + '
'
			DELETE FROM #StagingElement WHERE StagingElementName = @StagingElementName
			
		END	
	     
		--Populate Footer Level Logic
		SELECT @SQL_TableType = @SQL_TableType + '  PRIMARY KEY CLUSTERED 
(
	' + @Sql_PrimaryKey + '
) 
)
GO

' 

		SELECT @OutputSQL = @SQL_TableType

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