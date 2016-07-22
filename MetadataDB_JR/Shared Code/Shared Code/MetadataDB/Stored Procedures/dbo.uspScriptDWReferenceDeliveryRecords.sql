






-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWReferenceDeliveryRecords]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY


		DECLARE @DWReference_ModelDB AS VARCHAR(100)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )

		DECLARE @Sql_Proc_Name AS VARCHAR(MAX) = ''
		DECLARE @SQL_Print AS VARCHAR(MAX) = ''
		DECLARE @Sql_Extract_ALL AS VARCHAR(MAX) = ''
		
		----Declare layer object variables
		DECLARE @ETLType AS VARCHAR(MAX)
		DECLARE @SourceEntity AS VARCHAR(MAX)
		DECLARE @SourceTable AS VARCHAR(MAX)
		DECLARE @ErrorTable AS VARCHAR(MAX)
		DECLARE @ETLEntity AS VARCHAR(MAX)
		DECLARE @DestEntity AS VARCHAR(MAX)
		DECLARE @DestEntityID AS VARCHAR(MAX)
		DECLARE @DestTable AS VARCHAR(MAX)
		DECLARE @DestType AS VARCHAR(MAX)
		DECLARE @InfSourceBK AS VARCHAR(MAX)
		DECLARE @SourceLayerID AS VARCHAR(MAX)
		DECLARE @DestLayerID AS VARCHAR(MAX)
		DECLARE @ExecutionOrder AS INT
		DECLARE @InsertOnly AS BIT
	
		if object_id ('tempdb..#ETL' ) is not null
		   DROP TABLE #ETL

		CREATE TABLE #ETL (
			ETLType nvarchar(40) NOT NULL,
			SourceEntity nvarchar(100) NOT NULL, 
			DestEntity nvarchar(100) NOT NULL,
			SourceEntityID nvarchar(100) NOT NULL, 
			DestEntityID nvarchar(100) NOT NULL,
			DestTable nvarchar(100) NOT NULL,
			DestType nvarchar(100) NOT NULL,
			InfSourceBK nvarchar(100) NULL,
			InfDestBK nvarchar(100) NULL,
			SourceTable nvarchar(100) NULL,
			ErrorTable nvarchar(100) NULL,
			SourceLayerID nvarchar(100) NULL,
			DestLayerID nvarchar(100) NULL,
			ExecutionOrder INT NULL,
			InsertOnly BIT NULL
		) 

		--insert Type1 Dimension Load Objects into table.
		INSERT INTO #ETL
		SELECT DISTINCT
			DWObjectType.DWObjectTypeID AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject.DWObjectID AS DestEntityID,
			DWLayer.DWLayerAbbreviation + '.' + 'Dim' + DWOBject.DWObjectName AS DestTable,
			'Dim' AS DestType,
			'' AS InfSourceBK,
			'' AS InfDestBK,
			'[ext_' + DWObject.DWLayerID + '].[' + DWOBject.DWObjectName + ']' AS SourceTable,
			'NULL' AS ErrorTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject.DWLayerID AS DestLayerID,
			CASE 
				--Check if Object has GrandParents. If so set order to 30
				WHEN COUNT(DISTINCT DWElement2.EntityLookupObjectID) > 0 THEN 30
				--Check if Object has Parents. If so set order to 20
				WHEN COUNT(DISTINCT DWElement.EntityLookupObjectID) > 0 THEN 20
				ELSE 10
			END AS ExecutionOrder,
			0 AS InsertOnly
		FROM dbo.DWOBject DWOBject
			INNER JOIN dbo.DWObjectType DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWElement DWElement ON DWOBject.DWObjectID = DWElement.DWObjectID
			LEFT JOIN dbo.DWOBject DWOBject2 ON  
				DWElement.EntityLookupObjectID = DWOBject2.DWObjectID
			LEFT JOIN dbo.DWElement DWElement2 ON DWObject2.DWObjectID = DWElement2.DWObjectID
		WHERE DWLayerType = 'Base' AND 
			DWObject.DWObjectTypeID IN ('DIM-SCD1') and DWObject.IncludeInBuild = 1  
		GROUP BY 
			DWObjectType.DWObjectTypeID, 
			DWOBject.DWObjectName,
			DWOBject.DWObjectID,
			DWLayer.DWLayerAbbreviation,
			DWObject.DWLayerID
		ORDER BY DWObject.DWLayerID, DWObject.DWObjectName


		--insert Inferred Member Loads into table.
		INSERT INTO #ETL
		SELECT
			'InferredMemberLoad' AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWObject2.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWObject2.DWObjectID AS DestEntityID,
			DWLayer2.DWLayerAbbreviation + '.' + 'Dim' + DWOBject2.DWObjectName AS DestTable,
			'Dim' AS DestType,
			DWElement.DWElementName AS InfSourceBK,
			DWElement2.DWElementName AS InfDestBK,
			'[ext_' + DWObject.DWLayerID + '].[' + DWOBject.DWObjectName + ']' AS SourceTable,
			'NULL' AS ErrorTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject2.DWLayerID AS DestLayerID,
			100 + (((ROW_NUMBER() OVER (PARTITION BY DWObject2.DWObjectName ORDER BY DWOBject.DWObjectName, DWElement.DWElementName))-1)*10) AS ExecutionOrder,
			0 AS InsertOnly
		FROM dbo.DWOBject DWOBject
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWElement DWElement ON 
				DWOBject.DWObjectID = DWElement.DWObjectID
			LEFT JOIN dbo.DWOBject DWOBject2 ON  
				DWElement.EntityLookupObjectID = DWOBject2.DWObjectID
			LEFT JOIN dbo.DWLayer DWLayer2 
				ON DWObject2.DWLayerID = DWLayer2.DWLayerID
			LEFT JOIN dbo.DWElement DWElement2 ON  
				DWOBject2.DWObjectID = DWElement2.DWObjectID 
				AND DWElement2.BusinessKeyOrder = 1
		WHERE   
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('FACT-ACCUMULATING', 'FACT-SNAPSHOTHIST', 'FACT-SNAPSHOT', 'REF-CHANGING-FACT') and 
			DWOBject.IncludeInBuild = 1 AND DWElement.InferredMemberLoad = 1 AND DWOBject2.DWObjectID IS NOT NULL  
		
		--insert SnowFlake Member Loads into table.
		INSERT INTO #ETL
		SELECT
			'SnowFlakeMemberLoad' AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject2.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject2.DWObjectID AS DestEntityID,
			DWLayer2.DWLayerAbbreviation + '.' + 'Dim' + DWOBject2.DWObjectName AS DestTable,
			'Dim' AS DestType,
			DWElement.DWElementName AS InfSourceBK,
			DWElement2.DWElementName AS InfDestBK,
			'[' + DWLayer.DWLayerAbbreviation + '].[Dim' + DWOBject.DWObjectName + ']' AS SourceTable,
			'NULL' AS ErrorTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject2.DWLayerID AS DestLayerID,
			500 + (((ROW_NUMBER() OVER (PARTITION BY DWObject2.DWObjectName ORDER BY DWOBject.DWObjectName))-1)*10) AS ExecutionOrder,
			1 AS InsertOnly
		FROM dbo.DWOBject DWOBject	
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
			INNER JOIN dbo.DWElement DWElement ON 
				DWOBject.DWObjectID = DWElement.DWObjectID
			LEFT JOIN dbo.DWOBject DWOBject2 ON 
				DWElement.EntityLookupObjectID = DWOBject2.DWObjectID
			LEFT JOIN dbo.DWLayer DWLayer2 
				ON DWObject2.DWLayerID = DWLayer2.DWLayerID
			LEFT JOIN dbo.DWElement DWElement2 ON  
				DWOBject2.DWObjectID = DWElement2.DWObjectID 
				AND DWElement2.BusinessKeyOrder = 1
		WHERE  
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('DIM-SCD1', 'DIM-SCD2') 
			AND DWOBject.IncludeInBuild = 1 AND DWElement.InferredMemberLoad = 1 AND DWOBject2.DWObjectID IS NOT NULL  		
	
		--insert Fact \ Bridge Loads into table.
		INSERT INTO #ETL
		SELECT
			DWOBject.DWObjectTypeID AS ETLType, 
			DWOBject.DWObjectName AS SourceEntity,
			DWOBject.DWObjectName AS DestEntity,
			DWOBject.DWObjectID AS SourceEntityID,
			DWOBject.DWObjectID AS DestEntityID,
			DWLayer.DWLayerAbbreviation + '.' + (CASE WHEN DWOBject.DWObjectTypeID LIKE '%fact%' THEN 'Fact' WHEN DWOBject.DWObjectTypeID LIKE '%Bridge%' THEN 'Dim' ELSE '' END) + DWOBject.DWObjectName  AS DestTable,
			(CASE WHEN DWOBject.DWObjectTypeID LIKE '%fact%' THEN 'Fact' WHEN DWOBject.DWObjectTypeID LIKE '%Bridge%' THEN 'Dim' ELSE '' END) AS DestType,
			'' AS InfSourceBK,
			'' AS InfDestBK,
			'[ext_' + DWObject.DWLayerID + '].[' + DWOBject.DWObjectName + ']' AS SourceTable,
			'err_' + DWObject.DWLayerID + '.' + DWOBject.DWObjectName AS ErrorTable,
			DWObject.DWLayerID AS SourceLayerID,
			DWObject.DWLayerID AS DestLayerID,
			1000 AS ExecutionOrder,
			0 AS InsertOnly
		FROM dbo.DWOBject DWOBject	
			INNER JOIN dbo.DWObjectType DWObjectType 
				ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
			INNER JOIN dbo.DWLayer DWLayer 
				ON DWObject.DWLayerID = DWLayer.DWLayerID
		WHERE 
			DWLayer.DWLayerType = 'Base' 
			AND DWOBject.DWObjectTypeID IN ('FACT-SNAPSHOT', 'FACT-TRANSACTION', 'FACT-SNAPSHOTHIST', 'FACT-ACCUMULATING', 'DIM-SCD2-BRIDGE', 'DIM-SCD1-BRIDGE')  AND IncludeInBuild = 1
		ORDER BY DWObjectName

		WHILE (SELECT COUNT(*) FROM #ETL) > 0
		BEGIN
			SELECT TOP 1 
				@ETLType = ETLType,
				@SourceEntity = SourceEntity,
				@DestEntity = DestEntity,
				@DestEntityID = DestEntityID,
				@DestTable = DestTable,
				@DestType = DestType,
				@InfSourceBK = COALESCE(InfSourceBK, ''),
				@SourceTable = SourceTable,
				@ErrorTable = ErrorTable,
				@SourceLayerID = SourceLayerID,
				@DestLayerID = DestLayerID,
				@ExecutionOrder = ExecutionOrder,
				@InsertOnly = InsertOnly
			FROM #ETL
			ORDER BY ExecutionOrder, DestEntityID, SourceEntity


			SELECT @ETLEntity = (CASE WHEN @ETLType IN ('InferredMemberLoad','SnowFlakeMemberLoad') THEN REPLACE(@InfSourceBK, 'ID', '') ELSE @DestEntity END) +  
		(CASE WHEN @ETLType IN ('InferredMemberLoad','SnowFlakeMemberLoad') THEN 'From' + @SourceEntity ELSE '' END)

			SELECT @Sql_Proc_Name = 'dbo.uspDeliver_' + @DestLayerID + @DestType + @ETLEntity 
			SELECT @SQL_Print = 
'INSERT INTO [dbo].[DeliveryControl] ([DeliveryPackageName], [ProcessType], [DeliveryTable], [ExtractTable], [SourceIdentifier], [ExecutionOrder], [InsertOnly])
VALUES  (''' + @Sql_Proc_Name + ''',''SP''  ,''' + @DestTable + '''  ,''' + @SourceTable + ''',''' + @SourceLayerID + '_' + @SourceEntity + '''  ,' + CAST(@ExecutionOrder AS VARCHAR) + ', ' + CAST(@InsertOnly AS VARCHAR) + ')
GO
'

			SELECT @Sql_Extract_ALL =  @Sql_Extract_ALL + @SQL_Print
					
		--Delete processed row from tablelist
			DELETE FROM #ETL WHERE @DestEntityID = DestEntityID AND @ExecutionOrder = ExecutionOrder

	
		END
		

			--print dynamic sql

		SELECT @Sql_Extract_ALL = '
USE ' + @DWReference_ModelDB + '
GO

PRINT N''Start Inserting DeliveryControl Records...''
GO

-----------------------------------------
--Printing InsertSQL
-----------------------------------------
'	+ COALESCE(@Sql_Extract_ALL,'')  + '

PRINT N''Finished Inserting DeliveryControl Records...''
GO

'
						

		IF OBJECT_ID('tempdb..##ScriptsTable') IS NOT NULL
		BEGIN
			DELETE FROM ##ScriptsTable WHERE ScriptType = 'DW_Extract_Objects'
			INSERT INTO ##ScriptsTable (ScriptOrder, ScriptType, Script)
			SELECT 2, 'DW_Extract_Objects', @Sql_Extract_ALL
		END
		
		EXEC dbo.udpLongPrint @Sql_Extract_ALL
		
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