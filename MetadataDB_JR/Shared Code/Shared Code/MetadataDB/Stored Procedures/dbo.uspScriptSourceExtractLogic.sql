
-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptSourceExtractLogic]
    @MappingSetID VARCHAR(40)
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

		DECLARE @DWReference_ModelDB AS VARCHAR(100)
		DECLARE @EndDate AS VARCHAR(19)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		SET @EndDate = (SELECT CONVERT(VARCHAR(19), GETDATE(), 121)) 

	     --Mapping set info
		DECLARE @MappingSetDesc AS VARCHAR(4000),
		  @MappingSetSource AS VARCHAR(100),
		  @MappingSetTarget AS VARCHAR(100)

		--Mapping info
		DECLARE @MappingComments AS VARCHAR(4000)

		--Mapping element info
		DECLARE @MappingElementComments AS VARCHAR(4000)
		  
		--DWObject info
		DECLARE @DWObjectDesc AS VARCHAR(4000),
		  @DWObjectName AS VARCHAR(100)
		
		--DWElement info
		DECLARE @DWElementName AS VARCHAR(4000),
		  @DWElementDesc AS VARCHAR(100),
		  @BuseinssKeyOrder AS VARCHAR(100),
		  @DataType AS VARCHAR(100)


		DECLARE @MappingID AS VARCHAR(MAX) = ''
		DECLARE @ExtractPackageName AS NVARCHAR(MAX) = ''
		DECLARE @ExtractTable AS VARCHAR(MAX) = ''
		DECLARE @ExtractProcessType VARCHAR(MAX) = ''
		DECLARE @ETLImplementationTypeID VARCHAR(MAX) = ''
		--DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		DECLARE @SourceQuery NVARCHAR(MAX) 
		DECLARE @SourceQueryMapping NVARCHAR(MAX) 
		DECLARE @NameWidth AS INT = 30
		DECLARE @DataTypeWidth AS INT = 15
		DECLARE @DescWidth AS INT = 100
		DECLARE @CommentsWidth AS INT = 100

		IF OBJECT_ID ('tempdb..#ExtractPackage_List' ) IS NOT NULL
		   DROP TABLE #ExtractPackage_List

		SELECT 
			 Mapping.MappingID,
			 --In the case where we have two or more mappings from the same mapping set that get mapped to the same DWObject, we need to create a seperate ExtractPackageName to
			 --allow us to split out the control for this extra load. In this case we require one of those objects to have a value in the Mapping.AlternatePackageName Field. This
			 --Value will get used as the ExtractPackageName in preference to the default ExtractPackageName.
			CASE wHEN COALESCE(Mapping.AlternatePackageName,'') = '' THEN ('extract_' + DWObjectID) ELSE ('extract_' + Mapping.AlternatePackageName) END AS ExtractPackageName,
			('[ext_' + DWLayer.DWLayerID + '].[' + DWObjectName + ']') AS ExtractTable,
			Mapping.DefaultETLImplementationTypeID AS ETLImplementationTypeID,
			ETLImplementationType.[ExtractProcessType],
			DWObject.DWObjectName AS DWObjectName,
			DWObject.DWObjectDesc AS DWObjectDesc,
			MappingSetDesc AS MappingSetDesc,
			MappingSetSource AS MappingSetSource,
			MappingSetTarget AS MappingSetTarget,
			MappingComments AS MappingComments
		INTO #ExtractPackage_List
		FROM dbo.DWLayer DWLayer 
			INNER JOIN dbo.DWObject DWObject 
				ON DWLayer.DWLayerID = DWObject.DWLayerID
			INNER JOIN dbo.Mapping Mapping 
				ON Mapping.TargetObjectID = DWObjectID
			INNER JOIN dbo.MappingSetMapping MappingSetMapping
				ON Mapping.MappingID = MappingSetMapping.MappingID 
			LEFT JOIN dbo.ETLImplementationType ETLImplementationType
				ON ETLImplementationType.ETLImplementationTypeID = Mapping.DefaultETLImplementationTypeID
			 LEFT JOIN dbo.MappingSet MappingSet
				ON MappingSetMapping.MappingSetID = MappingSet.MappingSetID
		WHERE 
			DWLayerType = 'Base'
			AND DWObject.IncludeInBuild = 1
			AND DWLayer.DWLayerID <> 'ref'
			AND MappingSetMapping.MappingSetID = @MappingSetID

		WHILE (SELECT COUNT(*) FROM #ExtractPackage_List) > 0
		BEGIN
			SELECT TOP 1 
				@MappingID = COALESCE(MappingID, ''),
				@ExtractPackageName = COALESCE(ExtractPackageName, ''),
				@ExtractTable = COALESCE(ExtractTable, ''),
				@ExtractProcessType = COALESCE(ExtractProcessType, ''),
				@ETLImplementationTypeID = COALESCE(ETLImplementationTypeID, ''),
				@DWObjectName = COALESCE(DWObjectName, ''),
				@DWObjectDesc = COALESCE(DWObjectDesc, ''),
				@MappingSetDesc = COALESCE(MappingSetDesc, ''),
				@MappingSetSource = COALESCE(MappingSetSource, ''),
				@MappingSetTarget = COALESCE(MappingSetTarget, ''),
				@MappingComments = COALESCE(MappingComments, '')
			FROM #ExtractPackage_List 
			ORDER BY MappingID

			 SET @SourceQuery = NULL
			 SET @SourceQueryMapping = NULL
				
			 IF @ETLImplementationTypeID IN ('SP_Bulkload', 'SQL_Bulkload') 
			 BEGIN
    				EXEC [dbo].[uspScriptSourceObject_Extract] @MappingID = @MappingID, @SourceQuery = @SourceQuery OUTPUT, @SourceQueryMapping = @SourceQueryMapping OUTPUT, @ExtractPackageName = @ExtractPackageName
			 END

			SELECT @SQL_Print = @SQL_Print + '

--=================================================================================================================================================================
--=================================================================================================================================================================


-- Table Name: ' +  @DWObjectName + '
-- Table Desc: ' + @DWObjectDesc + '

--    ColumnName	                DataType		  Column Description
'

			 IF OBJECT_ID('tempdb..#ExtractLayerElements') IS NOT NULL
				DROP TABLE #ExtractLayerElements

			 SELECT
				me.MappingComments AS MappingElementComments,
				DWElementDesc,
				CASE 
					   WHEN BusinessKeyOrder IS NULL
						  THEN 99
					   ELSE BusinessKeyOrder
					   END AS 'BusinessKeyOrder'
				,ddt.DataType AS DataType
				,ddt.DomainDataTypeID
				,de.DWElementName
			 INTO #ExtractLayerElements
			 FROM dbo.MappingElement me
			 INNER JOIN [dbo].[DWElement] de
				ON me.TargetElementID = de.DWElementID
			 INNER JOIN [dbo].[DomainDataType] ddt
				ON de.DomainDataTypeID = ddt.DomainDataTypeID
			 WHERE MappingID = @MappingID
			 ORDER BY 1
				,de.DWElementName

			 WHILE (SELECT COUNT(*) FROM #ExtractLayerElements) > 0
			 BEGIN
				SELECT TOP 1 
				    @DataType = COALESCE(DataType, '')
				    ,@DWElementName = COALESCE(DWElementName, '')
				    ,@DWElementDesc = COALESCE(DWElementDesc, '')
				FROM #ExtractLayerElements
				ORDER BY BusinessKeyOrder
				    ,DWElementName

				SET @SQL_Print = @SQL_Print + '
--    '			    + left(ltrim(@DWElementName + '                                                                                                                 '), @NameWidth)
				    + left(ltrim(@DataType + '                                                                                                                 '), @DataTypeWidth)
				    + left(ltrim(@DWElementDesc + '                                                                                                                 '), @DescWidth)

				DELETE
				FROM #ExtractLayerElements
				WHERE DWElementName = @DWElementName
			 END

			SELECT @SQL_Print = @SQL_Print + '


--Extract Package Name: ' + @ExtractPackageName + '
--Extract Logic:' + COALESCE(
				    REPLACE(
					   REPLACE(
						  REPLACE(
							 REPLACE(
								REPLACE(
								    REPLACE(@SourceQuery,'"','')
								    ,'+ (DT_WSTR, 10)@[User::ExtractJobID] +', '1')
								,''' + (DT_WSTR, 10)@[User::ExtractControlID] + ''','1')
							 ,' + @[User::Suite] + ','<CpnyID, VARCHAR(50), >')
						  ,' + @[User::ExtractStartTime] + ', '1900-01-01 00:00:00') 
					   ,' + @[User::ExtractEndTime] + ',@EndDate)
				    ,'') + '

'
					
		    --Delete processed row from tablelist
			    DELETE FROM #ExtractPackage_List WHERE  @MappingID = MappingID

		    END

		--print dynamic sql
		SELECT @SQL_Print = COALESCE(@SQL_Print,'')


						
		EXEC dbo.udpLongPrint @SQL_Print
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