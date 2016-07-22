




-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWStagingTableBatch_STG]
     @CompressionType VARCHAR(100) = 'PAGE',
	@StagingObjectID VARCHAR(MAX),
	@AlternatePackageName VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

	    DECLARE @SQL_Table AS VARCHAR(MAX) = ''

	    DECLARE @Sql_StagingTable AS VARCHAR(MAX)
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
		  LEFT JOIN dbo.Mapping Mapping ON StagingObject.StagingObjectID = Mapping.TargetObjectID
		WHERE @StagingObjectID = StagingObjectID AND @AlternatePackageName = COALESCE(AlternatePackageName,'')

		SELECT @FullStagingObjectName = @StagingObjectName + (CASE WHEN COALESCE(@AlternatePackageName,'') = '' THEN '' ELSE ('_' +  @AlternatePackageName) END) 

		  SET @StagingJobIDDataType = 'Integer'
		  --Flat files have a seperate staging table
    		  SELECT @Sql_StagingTable = '
PRINT N''Dropping Table ' + @StagingOwnerID + '.STG_' + @FullStagingObjectName + '...''
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @StagingOwnerID + '.STG_' + @FullStagingObjectName + ''') AND type in (N''U''))
    DROP TABLE ' + @StagingOwnerID + '.STG_' + @FullStagingObjectName + '
GO

PRINT N''Creating Table ' + @StagingOwnerID + '.STG_' + @FullStagingObjectName + '...''
GO

CREATE TABLE ' + @StagingOwnerID + '.STG_' + @FullStagingObjectName + ' (
	StagingJobID ' + @StagingJobIDDataType + ' NOT NULL
'


	     --POPULATE #StagingElement
	     if object_id ('tempdb..#StagingElement' ) is not null
		   DROP TABLE #StagingElement

		SELECT 
		  StagingElementName, StagingElementOrder, BusinessKeyOrder, DataType
		  , FlatFileStagingDataType
	     INTO #StagingElement
		FROM dbo.StagingElement StagingElement
		  LEFT JOIN dbo.DomainDataType DomainDataType ON StagingElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
		WHERE StagingObjectID = @StagingObjectID



		WHILE (SELECT COUNT(*) FROM #StagingElement) > 0
		BEGIN
			SELECT TOP 1 @StagingElementName = StagingElementName,
				@StagingElementOrder = StagingElementOrder,
				@BusinessKeyOrder = COALESCE(BusinessKeyOrder,0),
				@DataType = COALESCE(FlatFileStagingDataType, DataType)
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
			

			SELECT @Sql_StagingTable = @Sql_StagingTable + '   ,' + @StagingElementName + ' ' + @DataType + @AttributeNull + '			
'

			DELETE FROM #StagingElement WHERE StagingElementName = @StagingElementName
			
			
		END	

--		  Flat files have a seperate staging table
    		  SELECT @Sql_StagingTable = @Sql_StagingTable + 
'    CONSTRAINT [PK_' + @StagingOwnerID + '_STG_' + @FullStagingObjectName + '] PRIMARY KEY CLUSTERED 
(
	' + @Sql_PrimaryKey + '
)
)
GO

'

		SELECT @Sql_Table = COALESCE(@Sql_StagingTable,'') 

		SELECT @OutputSQL = @Sql_Table


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