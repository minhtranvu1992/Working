





-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWStagingXMLMergeProcs]
	@StagingObjectID VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

   	    DECLARE @SQL_Proc AS VARCHAR(MAX) = ''
	    DECLARE @SQL_UpdateSP AS VARCHAR(MAX)				--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet0 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet1 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet2 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet3 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet6 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet7 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet8 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet9 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet10 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet11 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet12 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table
	    DECLARE @SQL_UpdateSP_Snippet13 AS VARCHAR(MAX)		--Stored Procedure to update ODS Table from feed table

	    --Declare feed variables
	    DECLARE @StagingObjectName AS VARCHAR(MAX)
	    DECLARE @StagingOwnerID AS VARCHAR(MAX)
	    DECLARE @StagingObjectDesc AS VARCHAR(MAX)

	    DECLARE @FullStagingObjectName AS VARCHAR(MAX)
	    --DECLARE @StagingJobIDDataType AS VARCHAR(MAX)
	
	    --Declare Attribute variables
	    DECLARE @StagingElementID AS VARCHAR(100)
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

		-- Store Proc Header level logic
		SELECT @SQL_UpdateSP_Snippet = '
PRINT N''Dropping Procedure ' + @StagingOwnerID + '.uspUpdate_' + @FullStagingObjectName + '...''
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @StagingOwnerID + '.uspUpdate_' + @FullStagingObjectName + ''') AND type in (N''P'', N''PC''))
DROP PROCEDURE ' + @StagingOwnerID + '.uspUpdate_' + @FullStagingObjectName + '
GO

PRINT N''Creating Procedure ' + @StagingOwnerID + '.uspUpdate_' + @FullStagingObjectName + '...''
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:		Stephen Lawson	
-- Create date: ' + CONVERT(CHAR(10), GETDATE(), 121) + '
-- Description:	This stored procedure merges the
-- Insert Data  
--		from: ESB Message 
--		into: ' + @StagingOwnerID + '.ODS_' + @FullStagingObjectName + '
-- ====================================================================================
CREATE PROCEDURE ' + @StagingOwnerID + '.uspUpdate_' + @FullStagingObjectName + ' 
	-- Add the parameters for the stored procedure here
	@xmlString NVARCHAR(MAX) 
AS
BEGIN
	BEGIN TRY
	   -- SET NOCOUNT ON added to prevent extra result sets from
	   -- interfering with SELECT statements.
	   SET NOCOUNT ON;

	   -- Insert statements for procedure here

	   -- Create Variables
    	   DECLARE @AuditDate AS SMALLDATETIME
			
	   SELECT @AuditDate = CAST(Getdate() AS SMALLDATETIME)

	   DECLARE @xml_valid AS xml(' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Schema)
	   DECLARE @' + @StagingOwnerID + '_' + @FullStagingObjectName + ' AS ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Table
	   --DECLARE @StagingJobID uniqueidentifier
	   
	   --Test whether the xml is well formed and valid. This will through an error if it fails
	   SET @xml_valid = @xmlString

	   --Prepare the untyped xml document		
	   DECLARE @idoc int
	   EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlString; 

	   INSERT INTO @' + @StagingOwnerID + '_' + @FullStagingObjectName + '
	   SELECT *
	   FROM       OPENXML (@idoc, ''/' + @StagingOwnerID + '_' + @FullStagingObjectName + '/' + @FullStagingObjectName + ''', 1) 
				WITH (
		   [MessageID] uniqueidentifier ''..//@MessageID'''			


SELECT @SQL_UpdateSP_Snippet1 = 
'		  );

			--Process Batch from Insert Table
			MERGE 
				' + @StagingOwnerID + '.ODS_' + @FullStagingObjectName + ' WITH (HOLDLOCK) ods_table
			USING 
				--Select batch from Insert table and calcuate the hashvalue			
				(SELECT *, 
						HASHBYTES(''MD5'', 
'

--@SQL_UpdateSP_Snippet3
		SELECT @SQL_UpdateSP_Snippet3 = '						) AS HashValue
				FROM	
					@' + @StagingOwnerID + '_' + @FullStagingObjectName + '
				) insert_batch
				--match on the key
				ON ('

--@SQL_UpdateSP_Snippet7					  
		SELECT @SQL_UpdateSP_Snippet7 = ')
				--when keys match, but hash values do not, then the row has been updated and we need to update that record	  
				WHEN MATCHED AND ods_table.HashValue <> insert_batch.HashValue THEN
					UPDATE SET
'

--@SQL_UpdateSP_Snippet9
		SELECT @SQL_UpdateSP_Snippet9 = '					  ods_table.HashValue = insert_batch.HashValue,
					  ods_table.LastChangeTime = @AuditDate,
					  ods_table.LastChangeStagingJobID = insert_batch.MessageID
				--when the key does not match, then the row is new and it needs to be inserted
				WHEN NOT MATCHED THEN
				INSERT ('

--@SQL_UpdateSP_Snippet11					  						
		SELECT @SQL_UpdateSP_Snippet11 = '
					   HashValue, 
					   LoadTime, 
					   LastChangeTime, 
					   LoadStagingJobID, 
					   LastChangeStagingJobID)
					VALUES (
'

--@SQL_UpdateSP_Snippet13					  						
		SELECT @SQL_UpdateSP_Snippet13 = '						insert_batch.HashValue,
						@AuditDate,
						@AuditDate,
						insert_batch.MessageID,
						insert_batch.MessageID
					);


		END TRY
		--Catch Section
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
			    @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ''-'')

		    /* Building the message string that will contain original error information */
		    SELECT  @ErrorMessage = N''Error %d, Level %d, State %d, Procedure %s, Line %d, ''
			+ ''Message: '' + ERROR_MESSAGE()

		    /* Raise an error: msg_str parameter of RAISERROR will contain the original error information */
		    RAISERROR (@ErrorMessage, @ErrorSeverity, 1, @ErrorNumber,
			    @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine)
		
		END CATCH
		--Finally Section
				
	END
	GO

'

	     --POPULATE #StagingElement
	     if object_id ('tempdb..#StagingElement' ) is not null
		   DROP TABLE #StagingElement

		SELECT 
		  StagingElementID, StagingElementName, StagingElementOrder, BusinessKeyOrder, DataType
	     INTO #StagingElement
		FROM dbo.StagingElement StagingElement
		  LEFT JOIN dbo.DomainDataType DomainDataType ON StagingElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
		WHERE StagingObjectID = @StagingObjectID
		

		SELECT @SQL_UpdateSP_Snippet0 = N''
		SELECT @SQL_UpdateSP_Snippet8 = N''
		SELECT @SQL_UpdateSP_Snippet10 = N''
		SELECT @SQL_UpdateSP_Snippet12 = N''
		
		WHILE (SELECT COUNT(*) FROM #StagingElement) > 0
		BEGIN
			SELECT TOP 1 
				@StagingElementID = StagingElementID,
				@StagingElementName = StagingElementName,
				@StagingElementOrder = StagingElementOrder,
				@BusinessKeyOrder = COALESCE(BusinessKeyOrder,0),
				@DataType = DataType 
			FROM #StagingElement
			ORDER BY COALESCE(BusinessKeyOrder, 999), StagingElementOrder
			
			SELECT @AttributeNull = ' NULL' 
			
			SELECT @SQL_UpdateSP_Snippet0 = @SQL_UpdateSP_Snippet0 + ',
		   [' + @StagingElementName + '] ' + @DataType + ' ''' + @StagingElementName + ''''

			IF @BusinessKeyOrder = 1
				BEGIN
					SELECT @SQL_UpdateSP_Snippet2 = '							  COALESCE(CAST(RTRIM(' + @StagingElementName + ') AS varchar(100)),''-'')
'
					SELECT @SQL_UpdateSP_Snippet6 = 'ods_table.' + @StagingElementName + ' = insert_batch.' + @StagingElementName
				END
			ELSE
				BEGIN
					IF (@BusinessKeyOrder >= 1)
						BEGIN
							SELECT @SQL_UpdateSP_Snippet6 = @SQL_UpdateSP_Snippet6 + ' AND ods_table.' + @StagingElementName + ' = insert_batch.' + @StagingElementName
						
						END
					ELSE
						BEGIN
							SELECT @SQL_UpdateSP_Snippet8 = @SQL_UpdateSP_Snippet8 + '					  ods_table.' + @StagingElementName + ' = insert_batch.' + @StagingElementName + ',
'
						END	
					
					SELECT @SQL_UpdateSP_Snippet2 = @SQL_UpdateSP_Snippet2 + '							+ COALESCE(CAST(RTRIM(' + @StagingElementName + ') AS varchar(100)),''-'')
'

				END

			SELECT @SQL_UpdateSP_Snippet10 = @SQL_UpdateSP_Snippet10 + '
					   ' + @StagingElementName + ','

			SELECT @SQL_UpdateSP_Snippet12 = @SQL_UpdateSP_Snippet12 + '						insert_batch.' + @StagingElementName + ',
'

			DELETE FROM #StagingElement WHERE StagingElementID = @StagingElementID
			
		END	

    		SELECT @SQL_UpdateSP = 
		  CAST(@SQL_UpdateSP_Snippet AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet0 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet1 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet2 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet3 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet6 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet7 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet8 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet9 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet10 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet11 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet12 AS VARCHAR(MAX))
		  + CAST(@SQL_UpdateSP_Snippet13 AS VARCHAR(MAX))

		SELECT @OutputSQL = @SQL_UpdateSP


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