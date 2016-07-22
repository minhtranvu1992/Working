







---- ====================================================================================
---- Author:		Stephen Lawson
---- Create date: 2014-05-14
---- Description:	This stored proc creates the ExtractControl Mapping Information
---- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptSourceObject_Extract]
	@MappingID NVARCHAR(MAX)
	,@SourceQuery NVARCHAR(MAX) OUTPUT
	,@SourceQueryMapping NVARCHAR(MAX) OUTPUT
	,@ExtractPackageName NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY

	   DECLARE @ErrorMessage NVARCHAR(4000)
	   DECLARE @FirstAttribute BIT
	   DECLARE @SourceObjectLogic AS VARCHAR(MAX)
	   DECLARE @PreAttributeLogic AS VARCHAR(MAX)
	   DECLARE @PostAttributeLogic AS VARCHAR(MAX)
	   DECLARE @Sql_Extract_Mapping AS VARCHAR(MAX) = ''
	   DECLARE @DomainDataTypeID VARCHAR(MAX)
	   DECLARE @SourceElementLogic VARCHAR(MAX)
	   DECLARE @SourceChangeTypeID VARCHAR(MAX)
	   DECLARE @PreMappingLogic VARCHAR(MAX)
	   DECLARE @PostMappingLogic VARCHAR(MAX)
	   DECLARE @DataType AS VARCHAR(100)
	   DECLARE @DWElementName AS VARCHAR(1000)
	   DECLARE @ETLImplementationTypeID AS VARCHAR(1000)
	   DECLARE @DeltaLogic VARCHAR(MAX)
	   DECLARE @UseDeltaAsLastChangeTime VARCHAR(MAX)
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
		  ,@ConnectionClassCategoryID = ConnectionClass.ConnectionClassCategoryID
		  ,@SourceType = ConnectionClassCategory.SourceType 
	   FROM dbo.DWLayer DWLayer
	   INNER JOIN dbo.DWObject DWObject
		  ON DWLayer.DWLayerID = DWObject.DWLayerID
	   LEFT JOIN dbo.Mapping Mapping
		  ON Mapping.TargetObjectID = DWObject.DWObjectID
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

	   IF OBJECT_ID('tempdb..#ExtractLayerElements') IS NOT NULL
		  DROP TABLE #ExtractLayerElements

	   SELECT CASE 
				WHEN BusinessKeyOrder IS NULL
				    THEN 99
				ELSE BusinessKeyOrder
				END AS 'BusinessKeyOrder'
		  ,me.SourceElementLogic
		  ,COALESCE(sdto.OverrideDataType, ddt.DataType) AS DataType
		  ,ddt.DomainDataTypeID
		  ,de.DWElementName
	   INTO #ExtractLayerElements
	   FROM dbo.MappingElement me
	   INNER JOIN [dbo].[DWElement] de
		  ON me.TargetElementID = de.DWElementID
	   INNER JOIN [dbo].[DomainDataType] ddt
		  ON de.DomainDataTypeID = ddt.DomainDataTypeID
	   LEFT JOIN [dbo].SourceDataTypeOverride sdto
		  ON ddt.DomainDataTypeID = sdto.DomainDataTypeID
		  AND sdto.ConnectionClassCategoryID = @ConnectionClassCategoryID
	   WHERE MappingID = @MappingID
	   ORDER BY 1
		  ,de.DWElementName
		

		SET @SourceQueryMapping = ''

	   IF @ETLImplementationTypeID = 'SQL_Bulkload' 
	   BEGIN

		IF @SourceType = @SourceType_OLEDBOracle 
		BEGIN
			SET @Sql_Extract_Mapping = '" 
	DECLARE'
		END
		ELSE
		BEGIN	
		  SET @Sql_Extract_Mapping = '"'
		END


		  IF @SourceChangeTypeID = 'delta'
		  BEGIN
			IF @SourceType = @SourceType_OLEDBOracle 
			BEGIN
					SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ' 
	varExtStartTime TIMESTAMP(3);
	varExtEndTime   TIMESTAMP(3);'
			END
			ELSE
			BEGIN
					SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	DECLARE @ExtStartTime AS DATETIME
	DECLARE @ExtEndTime   AS DATETIME'
			END
		  END

		  IF @SourceType = @SourceType_OLEDBOracle 
		  BEGIN
				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	varCpnyID       VARCHAR2(40);'

				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	varExtractJobID NUMBER(10);
	varSourceIdentifier VARCHAR2(40);
	
	BEGIN
	varExtractJobID := " + (DT_WSTR, 10)@[User::ExtractJobID] + " ;
	varSourceIdentifier := ''" + (DT_WSTR, 10)@[User::ExtractControlID] + "'' ;
	varCpnyID :=  ''" + @[User::Suite] + "'';
	'
		  END
		  ELSE
		  BEGIN
				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	DECLARE @CpnyID       AS NVARCHAR(40)'

				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	DECLARE @ExtractJobID AS INT
	DECLARE @SourceIdentifier NVARCHAR(40)
			
	SET @ExtractJobID = " + (DT_WSTR, 10)@[User::ExtractJobID] + "
	SET @SourceIdentifier = ''" + (DT_WSTR, 10)@[User::ExtractControlID] + "''
	SET @CpnyID =  ''" + @[User::Suite] + "'''
		  END
		  
		  IF @SourceChangeTypeID = 'delta'
		  BEGIN
			IF @SourceType = @SourceType_OLEDBOracle 
			BEGIN
				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	varExtStartTime := ''" + @[User::ExtractStartTime] + "''; 
	varExtEndTime := ''" + @[User::ExtractEndTime] + "'';'
			END
			ELSE
			BEGIN
				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
					SET @ExtStartTime = ''" + @[User::ExtractStartTime] + "'' 
					SET @ExtEndTime = ''" + @[User::ExtractEndTime] + "'''
			END
		  END

		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '

' + ISNULL(@PreMappingLogic, '')

		  IF @SourceType = @SourceType_OLEDBOracle 
		  BEGIN
		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping +'
	OPEN :result_cur
	FOR'
		  END

		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	
	SELECT '
		  SET @FirstAttribute = 1

		  WHILE (SELECT COUNT(*) FROM #ExtractLayerElements) > 0
		  BEGIN
			 SELECT TOP 1 @SourceElementLogic = COALESCE(SourceElementLogic, 'NULL')
				,@DataType = COALESCE(DataType, '')
				,@DWElementName = COALESCE(DWElementName, '')
				,@DomainDataTypeID = COALESCE(DomainDataTypeID, '')
			 FROM #ExtractLayerElements
			 ORDER BY BusinessKeyOrder
				,DWElementName

			 IF @FirstAttribute = 1
			 BEGIN
				SET @FirstAttribute = 0
				SET @SourceQueryMapping = @SourceQueryMapping + @DWElementName + ',' + @DWElementName
			 END
			 ELSE
			 BEGIN
				SET @SourceQueryMapping = @SourceQueryMapping + ';' + @DWElementName + ',' + @DWElementName
				SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ','
			 END

			 SET @PreAttributeLogic = 'CAST('
			 SET @PostAttributeLogic = ' AS ' + @DataType + ') AS ' + @DWElementName + '
	'

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

			 SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + @PreAttributeLogic + @SourceElementLogic + @PostAttributeLogic


			 DELETE
			 FROM #ExtractLayerElements
			 WHERE DWElementName = @DWElementName
		  END

		  IF @UseDeltaAsLastChangeTime = 1 AND @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ',' + @DeltaLogic + ' AS LastChangeTime
	'
		  END
		  ELSE IF @UseDeltaAsLastChangeTime = 0 AND @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ',LastChangeTime AS LastChangeTime
	'
		  END
		  ELSE IF @UseDeltaAsLastChangeTime IS NULL
		  BEGIN
			 SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ',NULL AS LastChangeTime
	'
		  END


		  IF @SourceType = @SourceType_OLEDBOracle 
		  BEGIN
		  
			SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ',varExtractJobID AS ExtractJobID
	,varSourceIdentifier AS SourceIdentifier
	'
		  END
		  ELSE
		  BEGIN

		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + ',@ExtractJobID AS ExtractJobID
	,@SourceIdentifier AS SourceIdentifier
	'	
		  END		

		  IF @DeltaLogic IS NOT NULL AND @SourceChangeTypeID = 'delta'
		  BEGIN
			 IF CHARINDEX('{Delta-DateRange}', @SourceObjectLogic) > 0
			 BEGIN
			  IF @SourceType = @SourceType_OLEDBOracle 
				BEGIN
				SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-DateRange}', @DeltaLogic + ' BETWEEN varExtStartTime AND varExtEndTime
	AND ')
				END
				ELSE
				BEGIN
				SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-DateRange}', @DeltaLogic + ' BETWEEN @ExtStartTime AND @ExtEndTime
	AND ')
				END
			 END

			 IF CHARINDEX('{Delta-WhereClauseDateRange}', @SourceObjectLogic) > 0
			 BEGIN

			 IF @SourceType = @SourceType_OLEDBOracle 
				BEGIN
				SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-WhereClauseDateRange}', 'WHERE ' + @DeltaLogic + ' BETWEEN varExtStartTime AND varExtEndTime
	')
				END
				ELSE
				BEGIN
				SET @SourceObjectLogic = REPLACE(@SourceObjectLogic, '{Delta-WhereClauseDateRange}', 'WHERE ' + @DeltaLogic + ' BETWEEN @ExtStartTime AND @ExtEndTime
	')
				END
			 END
		  END

		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + 'FROM ' + @SourceObjectLogic

	   	  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '

' + ISNULL(@PostMappingLogic, '')
		
		IF @SourceType = @SourceType_OLEDBOracle 
		BEGIN
			SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '
	END; 
"'
		END
		ELSE
		BEGIN
		  SET @Sql_Extract_Mapping = @Sql_Extract_Mapping + '"'
		END

	   END

	   IF @ETLImplementationTypeID = 'SP_Bulkload'
	   BEGIN
		  SET @Sql_Extract_Mapping = '"EXEC [dw].[' + @ExtractPackageName + '] @ExtractStartTime ''" + @[User::ExtractStartTime] + "'', 
@ExtractEndTime = ''" + @[User::ExtractEndTime] + "'' ,
@ExtractJobID = " + (DT_WSTR, 10)@[User::ExtractJobID] + ",
@SourceIdentifier = ''" + (DT_WSTR, 10)@[User::ExtractControlID] + "'',
@BatchSize = NULL,
@CompanyCode = ''" + @[User::Suite] + "''"'
	   END

	   SET @SourceQueryMapping = @SourceQueryMapping + ';LastChangeTime,LastChangeTime;ExtractJobID,ExtractJobID;SourceIdentifier,SourceIdentifier'
	   -- Add post mapping logic

	   --Normalise line endings
    	   SET @Sql_Extract_Mapping = REPLACE(REPLACE(REPLACE(REPLACE(@Sql_Extract_Mapping, CHAR(10), '~'), CHAR(13), '~'), '~~', '~'), '~', CHAR(13) + CHAR(10))

	   --Set output variable
	   SET @SourceQuery = @Sql_Extract_Mapping

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