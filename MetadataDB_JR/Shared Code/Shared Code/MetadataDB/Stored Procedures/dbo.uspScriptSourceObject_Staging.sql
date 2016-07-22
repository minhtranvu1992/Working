






---- ====================================================================================
---- Author:		Stephen Lawson
---- Create date: 2014-05-14
---- Description:	This stored proc creates the StagingControl Mapping Information
---- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptSourceObject_Staging]
	@MappingID NVARCHAR(MAX)
	,@SourceQuery NVARCHAR(MAX) OUTPUT
	,@SourceQueryMapping NVARCHAR(MAX) OUTPUT
	,@HeaderCheckString NVARCHAR(MAX) OUTPUT
	,@StagingPackageName NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY

	   DECLARE @ErrorMessage NVARCHAR(4000)
	   DECLARE @FirstAttribute INT
	   DECLARE @SourceObjectLogic AS VARCHAR(MAX)
	   DECLARE @PreAttributeLogic AS VARCHAR(MAX)
	   DECLARE @PostAttributeLogic AS VARCHAR(MAX)
	   DECLARE @Sql_Staging_Mapping AS VARCHAR(MAX) = ''
	   DECLARE @DomainDataTypeID VARCHAR(MAX)
	   DECLARE @SourceElementLogic VARCHAR(MAX)
	   DECLARE @SourceChangeTypeID VARCHAR(MAX)
	   DECLARE @PreMappingLogic VARCHAR(MAX)
	   DECLARE @PostMappingLogic VARCHAR(MAX)
	   DECLARE @DataType AS VARCHAR(100)
	   DECLARE @StagingElementName AS VARCHAR(1000)
	   DECLARE @ETLImplementationTypeID AS VARCHAR(MAX)
	   DECLARE @DeltaLogic VARCHAR(MAX)
	   DECLARE @UseDeltaAsLastChangeTime VARCHAR(MAX)
	   DECLARE @Delimiter VARCHAR(MAX)
	   DECLARE @ConnectionClassCategoryID VARCHAR(40)
	   
	   DECLARE @SourceType VARCHAR(40) 
	   DECLARE @SourceType_OLEDBOracle VARCHAR(40) = 'OLEDB_ORACLE' 

	   SELECT
		  @SourceObjectLogic = Mapping.SourceObjectLogic
		  ,@PreMappingLogic = Mapping.PreMappingLogic
		  ,@PostMappingLogic = Mapping.PostMappingLogic
		  ,@ETLImplementationTypeID = Mapping.DefaultETLImplementationTypeID 
		  ,@SourceChangeTypeID = Mapping.DefaultSourceChangeTypeID
		  ,@DeltaLogic = Mapping.DeltaLogic
		  ,@UseDeltaAsLastChangeTime = Mapping.UseDeltaAsLastChangeTime
		  ,@Delimiter = COALESCE(FlatFileDelimiter, '')
		  ,@ConnectionClassCategoryID = ConnectionClass.ConnectionClassCategoryID
		  ,@SourceType = ConnectionClassCategory.SourceType 
	   FROM dbo.StagingOwner StagingOwner
	   INNER JOIN dbo.StagingObject StagingObject
		  ON StagingOwner.StagingOwnerID = StagingObject.StagingOwnerID
	   LEFT JOIN dbo.Mapping Mapping
		  ON Mapping.TargetObjectID = StagingObject.StagingObjectID
	   LEFT JOIN dbo.MappingSetMapping MappingSetMapping
		  ON Mapping.MappingID = MappingSetMapping.MappingID
	   LEFT JOIN dbo.MappingInstance MappingInstance
		  ON MappingSetMapping.MappingSetID = MappingInstance.MappingSetID
	   LEFT JOIN dbo.Connection Connection
		  ON MappingInstance.SourceConnectionID = Connection.ConnectionID
	   LEFT JOIN dbo.ConnectionClass ConnectionClass
		  ON Connection.ConnectionClassID = ConnectionClass.ConnectionClassID
	   LEFT JOIN dbo.ConnectionClassCategory ConnectionClassCategory 
		  ON ConnectionClass.ConnectionClassCategoryID = ConnectionClassCategory.ConnectionClassCategoryID
	   WHERE 
		  Mapping.MappingID = @MappingID

	   IF @SourceChangeTypeID = 'delta' AND (@UseDeltaAsLastChangeTime IS NULL OR @UseDeltaAsLastChangeTime IS NULL)
	   BEGIN
		  SET @ErrorMessage = 'MappingID: ' + @MappingID + ' SourceCheangeType is of type: ' + @SourceChangeTypeID + ' DeltaLogic or UseDeltaAsLastChangeTime is null'

		  RAISERROR (@ErrorMessage,16,1);
	   END

	   IF OBJECT_ID('tempdb..#StagingLayerElements') IS NOT NULL
		  DROP TABLE #StagingLayerElements

	   SELECT CASE 
				WHEN BusinessKeyOrder IS NULL
				    THEN 99
				ELSE BusinessKeyOrder
				END AS 'BusinessKeyOrder'
		  ,MappingElement.SourceElementLogic
		  ,COALESCE(SourceDataTypeOverride.OverrideDataType, DomainDataType.DataType) AS DataType
		  ,DomainDataType.DomainDataTypeID
		  ,StagingElement.StagingElementName
		  ,StagingElement.StagingElementOrder
	   INTO #StagingLayerElements
	   FROM dbo.Mapping Mapping
	   INNER JOIN dbo.StagingElement StagingElement
		  ON Mapping.TargetObjectID = StagingElement.StagingObjectID
	   INNER JOIN dbo.DomainDataType DomainDataType
		  ON StagingElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
	   LEFT JOIN [dbo].SourceDataTypeOverride SourceDataTypeOverride
		  ON DomainDataType.DomainDataTypeID = SourceDataTypeOverride.DomainDataTypeID
		  AND SourceDataTypeOverride.ConnectionClassCategoryID = @ConnectionClassCategoryID
	   LEFT JOIN dbo.MappingElement MappingElement
		  ON MappingElement.TargetElementID = StagingElement.StagingElementID
	   WHERE Mapping.MappingID = @MappingID

	   SET @SourceQueryMapping = ''
	   SET @HeaderCheckString = ''

	   IF @ETLImplementationTypeID = 'SQL_Bulkload_Staging' 
	   BEGIN
		  
		  IF @SourceType = @SourceType_OLEDBOracle 
		  BEGIN
				SET @Sql_Staging_Mapping = '" 
	DECLARE'
		  END
		  ELSE
		  BEGIN
				SET @Sql_Staging_Mapping = '"'
		  END


			IF @SourceChangeTypeID = 'delta'
			BEGIN

				IF @SourceType = @SourceType_OLEDBOracle 
				BEGIN
					SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + ' 
	varExtStartTime TIMESTAMP(3);
	varExtEndTime   TIMESTAMP(3);'
				END
				ELSE
				BEGIN			  	
					SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	DECLARE @ExtStartTime AS DATETIME
	DECLARE @ExtEndTime   AS DATETIME'
				END
			END

			IF @SourceType = @SourceType_OLEDBOracle 
			BEGIN
			SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	varCpnyID       VARCHAR2(40);'

				SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	varStagingJobID NUMBER(10);
	
	BEGIN
	varStagingJobID := " + (DT_WSTR, 10)@[User::StagingJobID] + " ;
	varCpnyID :=  ''" + @[User::Suite] + "'';
	'
			END
			ELSE
			BEGIN
			 SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	DECLARE @CpnyID       AS NVARCHAR(40)'

		  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	DECLARE @StagingJobID AS INT
			
	SET @StagingJobID = " + (DT_WSTR, 10)@[User::StagingJobID] + "
	SET @CpnyID =  ''" + @[User::Suite] + "'''
			END
		 

		  IF @SourceChangeTypeID = 'delta'
		  BEGIN
			IF @SourceType = @SourceType_OLEDBOracle 
			BEGIN
			SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	varExtStartTime := ''" + @[User::ExtractStartTime] + "''; 
	varExtEndTime := ''" + @[User::ExtractEndTime] + "'';'
			END
			ELSE
			BEGIN							
				SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	SET @ExtStartTime = ''" + @[User::ExtractStartTime] + "'' 
	SET @ExtEndTime = ''" + @[User::ExtractEndTime] + "'''
			END
		  END

		  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '

' + ISNULL(@PreMappingLogic, '')


IF @SourceType = @SourceType_OLEDBOracle 
		  BEGIN
		  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping +'
	OPEN :result_cur
	FOR'
		  END


		  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '

	SELECT 
    '

	   END
	   
	   SET @FirstAttribute = 1

	   WHILE (SELECT COUNT(*) FROM #StagingLayerElements) > 0
	   BEGIN
		  SELECT TOP 1 @SourceElementLogic = COALESCE(SourceElementLogic, 'NULL')
			 ,@DataType = COALESCE(DataType, '')
			 ,@StagingElementName = COALESCE(StagingElementName, '')
			 ,@DomainDataTypeID = COALESCE(DomainDataTypeID, '')
		  FROM #StagingLayerElements
		  ORDER BY StagingElementOrder

		  IF @ETLImplementationTypeID = 'FlatFile_Bulkload_Staging' 
		  BEGIN
			 IF @FirstAttribute = 1
			 BEGIN
				SET @SourceQueryMapping = @SourceQueryMapping + @StagingElementName + ',' + @StagingElementName
				SET @HeaderCheckString = @StagingElementName
			 END
			 ELSE
			 BEGIN
				SET @SourceQueryMapping = @SourceQueryMapping + ';' + @StagingElementName + ',' + @StagingElementName
				SET @HeaderCheckString = @HeaderCheckString + @Delimiter + @StagingElementName
			 END
		  END

		  IF @ETLImplementationTypeID = 'SQL_Bulkload_Staging' 
		  BEGIN
			 IF @FirstAttribute = 1
			 BEGIN
				SET @SourceQueryMapping = @SourceQueryMapping + @StagingElementName + ',' + @StagingElementName
				--SET @Sql_Staging_Mapping = @Sql_Staging_Mapping 
			 END
			 ELSE
			 BEGIN
				SET @SourceQueryMapping = @SourceQueryMapping + ';' + @StagingElementName + ',' + @StagingElementName
			 END

			 SET @PreAttributeLogic = 'CAST('
			 SET @PostAttributeLogic = ' AS ' + @DataType + ') AS ' + @StagingElementName + '
    ,'

			 IF @DomainDataTypeID = 'SCODE' OR @DomainDataTypeID = 'ID'
			 BEGIN
				SET @PreAttributeLogic =  @PreAttributeLogic + 'UPPER('
				SET @PostAttributeLogic = ')' + @PostAttributeLogic 
			 END

			 IF @DataType LIKE '%char%'
			 BEGIN
				SET @PreAttributeLogic =  @PreAttributeLogic + 'LTRIM(RTRIM('
				SET @PostAttributeLogic = '))' + @PostAttributeLogic 
			 END

			 SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + @PreAttributeLogic + @SourceElementLogic + @PostAttributeLogic
		  END

		  SET @FirstAttribute = @FirstAttribute + 1

		  DELETE
		  FROM #StagingLayerElements
		  WHERE StagingElementName = @StagingElementName

	   END

	   IF @ETLImplementationTypeID = 'SQL_Bulkload_Staging' 
	   BEGIN
		  IF @UseDeltaAsLastChangeTime = 1 AND @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + @DeltaLogic + ' AS LastChangeTime
    ,'
		  END
		  ELSE IF @UseDeltaAsLastChangeTime = 0 AND @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + 'LastChangeTime AS LastChangeTime
    ,'
		  END
		  ELSE IF @UseDeltaAsLastChangeTime IS NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + 'NULL AS LastChangeTime
    ,'
		  END

			IF @SourceType = @SourceType_OLEDBOracle 
			BEGIN
				SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + 'varStagingJobID AS StagingJobID
'
			END
			ELSE
			BEGIN
				SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '@StagingJobID AS StagingJobID
'
			END

		  IF @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
				IF @SourceType = @SourceType_OLEDBOracle 
				BEGIN
					IF CHARINDEX('{Delta-DateRange}', @SourceObjectLogic) > 0
					BEGIN
					SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-DateRange}', @DeltaLogic + ' BETWEEN varExtStartTime AND varExtEndTime
		AND ')
					END

					IF CHARINDEX('{Delta-WhereClauseDateRange}', @SourceObjectLogic) > 0
					BEGIN
					SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-WhereClauseDateRange}', 'WHERE ' + @DeltaLogic + ' BETWEEN varExtStartTime AND varExtEndTime
		')
					END
				END
				ELSE
				BEGIN
					IF CHARINDEX('{Delta-DateRange}', @SourceObjectLogic) > 0
					BEGIN
					SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-DateRange}', @DeltaLogic + ' BETWEEN @ExtStartTime AND @ExtEndTime
		AND ')
					END

					IF CHARINDEX('{Delta-WhereClauseDateRange}', @SourceObjectLogic) > 0
					BEGIN
					SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-WhereClauseDateRange}', 'WHERE ' + @DeltaLogic + ' BETWEEN @ExtStartTime AND @ExtEndTime
		')
					END
				END
			 
		  END

		  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + 'FROM ' + @SourceObjectLogic

	   	  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '

' + ISNULL(@PostMappingLogic, '')

		IF @SourceType = @SourceType_OLEDBOracle 
		BEGIN
					SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '
	END; 
	"'
		END
		ELSE
		BEGIN
				  SET @Sql_Staging_Mapping = @Sql_Staging_Mapping + '"'
		END

	   END


	   SET @SourceQueryMapping = @SourceQueryMapping + ';StagingJobID,StagingJobID'
	   -- Add post mapping logic

	   --Normalise line endings
    	   SET @Sql_Staging_Mapping = REPLACE(REPLACE(REPLACE(REPLACE(@Sql_Staging_Mapping, CHAR(10), '~'), CHAR(13), '~'), '~~', '~'), '~', CHAR(13) + CHAR(10))

	   --Set output variable
	   SET @SourceQuery = @Sql_Staging_Mapping

	END TRY

	BEGIN CATCH
		/* rollback transaction if there is open transaction */
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		/* throw the catched error to trigger the error in SSIS package */
		DECLARE @ErrorNumber INT
			,@ErrorSeverity INT
			,@ErrorState INT
			,@ErrorLine INT
			,@ErrorProcedure NVARCHAR(200)

		/* Assign variables to error-handling functions that capture information for RAISERROR */
		SELECT @ErrorNumber = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE()
			,@ErrorLine = ERROR_LINE()
			,@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')

		/* Building the message string that will contain original error information */
		SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 'Message: ' + ERROR_MESSAGE()

		/* Raise an error: msg_str parameter of RAISERROR will contain the original error information */
		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,1
				,@ErrorNumber
				,@ErrorSeverity
				,@ErrorState
				,@ErrorProcedure
				,@ErrorLine
				)
	END CATCH
		--Finally Section
		/* clean up the temporary table */
END