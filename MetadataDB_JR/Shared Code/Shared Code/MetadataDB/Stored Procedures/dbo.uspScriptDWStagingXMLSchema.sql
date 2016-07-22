



-- ====================================================================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-06
-- Description:	This stored proc creates all the extract tables 
-- ====================================================================================
CREATE PROCEDURE [dbo].[uspScriptDWStagingXMLSchema]
	@StagingObjectID VARCHAR(MAX), 
	@OutputSQL VARCHAR(MAX) OUTPUT
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRY

  	    DECLARE @SQL_XMLSchema AS VARCHAR(MAX) = ''

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

	    DECLARE @XMLElementCollection AS VARCHAR(MAX)
	    DECLARE @XMLIndividualElement AS VARCHAR(MAX)
	    DECLARE @XMLCreateSimpleType AS Bit
	    DECLARE @XMLMinOccurs AS VARCHAR(MAX) 
	    DECLARE @XMLStringLength AS VARCHAR(MAX)
	    DECLARE @XMLDataType AS VARCHAR(MAX)

		SELECT TOP 1 
		  @StagingObjectName = StagingObjectName,
		  @StagingOwnerID = StagingOwnerID,
		  @StagingObjectDesc = StagingObjectDesc
		FROM  dbo.StagingObject StagingObject
		WHERE @StagingObjectID = StagingObjectID


		SELECT @FullStagingObjectName = @StagingObjectName

		-- Table Header level logic
		SELECT @SQL_XMLSchema = '
PRINT N''Dropping XML Schema Collection ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Schema...''
GO

IF  EXISTS (SELECT * FROM sys.xml_schema_collections xml_schema_collections INNER JOIN sys.schemas schemas ON xml_schema_collections.schema_id = schemas.schema_id WHERE xml_schema_collections.name = N''' + @FullStagingObjectName + '_Schema'' AND schemas.name = N''' + @StagingOwnerID + ''')		
    DROP XML SCHEMA COLLECTION  ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Schema
GO

PRINT N''Creating XML Schema Collection ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Schema...''
GO

CREATE XML SCHEMA COLLECTION ' + @StagingOwnerID + '.' + @FullStagingObjectName + '_Schema AS N''
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<xsd:element name="' + @StagingOwnerID + '_' + @FullStagingObjectName + '">
		<xsd:complexType>
			<xsd:complexContent>
				<xsd:restriction base="xsd:anyType">
					<xsd:sequence>
						<xsd:element name="' + @FullStagingObjectName + '" maxOccurs="unbounded">
							<xsd:complexType>
								<xsd:complexContent>
									<xsd:restriction base="xsd:anyType">
										<xsd:sequence>'

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
    			ORDER BY StagingElementOrder			


			SELECT @XMLCreateSimpleType = 0

			IF (@DataType LIKE '%char%' AND @DataType NOT LIKE '%Max%') 
			 BEGIN
				SELECT @XMLStringLength = SUBSTRING(@DataType, CHARINDEX('(', @DataType, 1) + 1, (LEN(@DataType) - CHARINDEX('(', @DataType, 1) - 1))
				SELECT @XMLCreateSimpleType = 1
			 END
						
			SELECT @XMLDataType = 
				    (CASE 
					   WHEN @DataType LIKE '%char%' THEN 'string'
					   WHEN @DataType IN ('integer','bit','bigint','tinyint', 'smallint') THEN 'integer'
					   WHEN @DataType IN ('date', '', '', '') THEN 'date'
					   WHEN @DataType IN ('datetime', '', '', '') THEN 'dateTime'
					   WHEN @DataType IN ('money', 'smallmoney') OR @DataType LIKE '%numeric%' OR @DataType LIKE '%decimal%'  THEN 'decimal'
					   WHEN @DataType IN ('float', '', '', '') THEN 'float'
				    END)
			
			SELECT @XMLMinOccurs = '0' 

			IF @BusinessKeyOrder = 1
			 BEGIN
				    SELECT @Sql_PrimaryKey = @StagingElementName + ' ASC'
				    SELECT @XMLMinOccurs = '1'
						
			 END
			ELSE IF (@BusinessKeyOrder >= 1)
			 BEGIN
				    SELECT @Sql_PrimaryKey = @Sql_PrimaryKey + ', ' + @StagingElementName + ' ASC'
				    SELECT @XMLMinOccurs = '1'					
			 END

		     IF (@XMLCreateSimpleType = 1)
			BEGIN
			    SELECT @XMLIndividualElement = '
											<xsd:element name="' + @StagingElementName + '" minOccurs="' + @XMLMinOccurs + '" maxOccurs="1">
												<xsd:simpleType>
													<xsd:restriction base="xsd:' + @XMLDataType  + '">
														<xsd:maxLength value="' + CAST(@XMLStringLength AS VARCHAR) + '" />
													</xsd:restriction>
												</xsd:simpleType>
											</xsd:element>'
			END
			ELSE
			BEGIN
			    SELECT @XMLIndividualElement = '
											<xsd:element name="' + @StagingElementName + '" type="xsd:' + @XMLDataType + '" minOccurs="' + @XMLMinOccurs + '" maxOccurs="1" />'
			END

			SELECT @SQL_XMLSchema = @SQL_XMLSchema + @XMLIndividualElement

			DELETE FROM #StagingElement WHERE StagingElementName = @StagingElementName
			
		END	
	     
		--Populate Footer Level Logic
		SELECT @SQL_XMLSchema = @SQL_XMLSchema + '
										</xsd:sequence>
									</xsd:restriction>
								</xsd:complexContent>
							</xsd:complexType>
						</xsd:element>
					</xsd:sequence>
					<xsd:attribute name="MessageID" type="xsd:string" use="required" />
				</xsd:restriction>
			</xsd:complexContent>
		</xsd:complexType>
	</xsd:element>
</xsd:schema>
''
GO
' 

		SELECT @OutputSQL = @SQL_XMLSchema

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