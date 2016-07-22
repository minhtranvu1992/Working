
CREATE PROCEDURE [dbo].[spUpdateSummaryControlCurrentDeliveryJobID]
	@ScheduleType VARCHAR(100)
AS
BEGIN
SET NOCOUNT ON
DECLARE @SummaryPackageName NVARCHAR(100)
DECLARE @SourceDatabaseName NVARCHAR(500)
DECLARE @ConnStr NVARCHAR(500)


DECLARE @sqlGen NVARCHAR(MAX) = ''



DECLARE curPackages CURSOR FOR
SELECT s.SummaryPackageName, ss.ConfiguredValue FROM [dbo].[SummaryControl] s 
INNER JOIN [dbo].SourceControl sc ON s.SourceControlID = sc.SourceControlID
INNER JOIN [dbo].SSISConfiguration ss ON sc.SSISConfigurationID = ss.SSISConfigurationID
OPEN curPackages
FETCH NEXT FROM curPackages INTO @SummaryPackageName, @ConnStr
WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @SourceDatabaseName = SUBSTRING(@ConnStr, 
	                                CHARINDEX('Initial Catalog', @ConnStr), 
						            CHARINDEX(';', @ConnStr, CHARINDEX('Initial Catalog', @ConnStr))- CHARINDEX('Initial Catalog', @ConnStr))
	SET @SourceDatabaseName = LTRIM(RTRIM(SUBSTRING(@SourceDatabaseName, CHARINDEX('=',@SourceDatabaseName) +1, LEN(@SourceDatabaseName))))

	SET @sqlGen = '
	DECLARE @FirstRun BIT = 1
	DECLARE @NoDpendancy BIT = 1
	DECLARE @TableName NVARCHAR(100) = ''''
	DECLARE @sqlQuery NVARCHAR(MAX) = ''''
	SET @sqlQuery = ''DECLARE @DeliveryJobID INT
	SELECT @DeliveryJobID = MAX(DeliveryJobID) FROM (''

	DECLARE cur CURSOR FOR
	SELECT DISTINCT referenced_schema_name + ''.'' + referenced_entity_name AS ''TableName''
	FROM ' + @SourceDatabaseName + '.sys.dm_sql_referenced_entities (''' + @SummaryPackageName + ''', ''OBJECT'') re
	INNER JOIN ' + @SourceDatabaseName + '.INFORMATION_SCHEMA.COLUMNS c ON c.TABLE_SCHEMA = re.referenced_schema_name AND c.TABLE_NAME = re.referenced_entity_name
	WHERE c.COLUMN_NAME = ''DeliveryJobID''
	OPEN cur
	FETCH NEXT FROM cur INTO @TableName
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @NoDpendancy = 0
		IF @FirstRun = 1
		BEGIN
			SET @FirstRun = 0
		END
		ELSE
		BEGIN
			SET @sqlQuery = @sqlQuery + '' UNION ALL
	''
		END
		SET @sqlQuery = @sqlQuery + ''SELECT MAX(DeliveryJobID) AS ''''DeliveryJobID'''' FROM ' + @SourceDatabaseName + '.'' + @TableName


		FETCH NEXT FROM cur INTO @TableName
	END
	CLOSE cur
	DEALLOCATE cur
	
	SET  @sqlQuery = @sqlQuery + ''
	) a

	UPDATE [dbo].[SummaryControl] SET [CurrentDeliveryJobID] = @DeliveryJobID WHERE [SummaryPackageName] = ''''' + @SummaryPackageName + '''''''
	IF @NoDpendancy = 0
	BEGIN 
		EXEC sp_executesql @sqlQuery
	END'

	EXEC sp_executesql @sqlGen

	FETCH NEXT FROM curPackages INTO @SummaryPackageName, @ConnStr
END
CLOSE curPackages
DEALLOCATE curPackages
	
------------------------------------------------------------------------------
-- 2.0 Return if there are any changes requiring Summary manager to process.
------------------------------------------------------------------------------
	SELECT ISNULL(MAX(ABS([LastDeliveryJobID] - [CurrentDeliveryJobID])), 0) AS 'ChangesFound' FROM [dbo].[SummaryControl] WHERE ISNULL([LastDeliveryJobID], -1) <> ISNULL([CurrentDeliveryJobID], -1) AND ScheduleType = @ScheduleType
END