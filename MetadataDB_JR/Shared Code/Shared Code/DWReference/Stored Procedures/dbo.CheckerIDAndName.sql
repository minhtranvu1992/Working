
CREATE PROCEDURE [dbo].[CheckerIDAndName]
@OnlyDifferent BIT
AS 
BEGIN 

	SET NOCOUNT ON
	DECLARE @TableName NVARCHAR(MAX)
	DECLARE @ID NVARCHAR(MAX)
	DECLARE @Name NVARCHAR(MAX)
	DECLARE @UniqName NVARCHAR(MAX)
	DECLARE @sqlQuery NVARCHAR(MAX) = ''

	IF OBJECT_ID('tempdb..#CheckTable') IS NOT NULL
	BEGIN
				DROP TABLE #CheckTable
	END
	SELECT TableName, ID, Name,UniqName
	INTO #CheckTable
	FROM (
	SELECT 'SourceControl' AS 'TableName', 'SourceControlID' AS 'ID', 'SourceName' AS 'Name', 'SourceName' AS 'UniqName'
	UNION
	SELECT 'Suite', 'SuiteID', 'SuiteName', 'SuiteName' AS 'UniqName'
	UNION
	SELECT 'SSISConfiguration', 'SSISConfigurationID', 'ConfigurationFilter', 'ConfigurationFilter' AS 'UniqName'
	UNION
	SELECT 'Schedule', 'ScheduleID', 'ScheduleName', 'ScheduleName' AS 'UniqName'
	UNION
	SELECT 'ExtractControl', 'ExtractControlID', 'ExtractPackageName', 'ExtractPackageName + ''_'' + CAST([SuiteID] AS NVARCHAR(10)) + ''_'' + CAST([ExecutionOrderGroup] AS NVARCHAR(10)) ' AS 'UniqName'
	UNION
	SELECT 'ExtractControl', 'SourceQuery', 'ExtractPackageName', 'ExtractPackageName + ''_'' + CAST([SuiteID] AS NVARCHAR(10)) + ''_'' + CAST([ExecutionOrderGroup] AS NVARCHAR(10)) ' AS 'UniqName'
	UNION
	SELECT 'DeliveryControl', 'DeliveryControlID', 'DeliveryPackageName', 'DeliveryPackageName' AS 'UniqName'
	UNION
	SELECT 'SummaryControl', 'SummaryControlID', 'SummaryPackageName', 'SummaryPackageName' AS 'UniqName'
	) a

	WHILE (SELECT COUNT(*) FROM #CheckTable) > 0
	BEGIN

	SELECT TOP 1 @TableName = TableName
					,@ID = ID
					,@Name = Name
					,@UniqName = UniqName
				FROM #CheckTable

	DECLARE @TempTableName NVARCHAR(MAX) = @TableName + @ID
	DECLARE @sql NVARCHAR(MAX) =
	'
	-------------------------------------------------------------------------------
	-- ' + @TableName + ' 
	-------------------------------------------------------------------------------
	IF OBJECT_ID(''tempdb..#DEVTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'DEVTable
	END
	SELECT ' + @UniqName + ' AS ''' + @Name + ''', ' + @ID +'
	INTO #' + @TempTableName + 'DEVTable
	FROM OPENROWSET(''SQLNCLI'', ''server=05W8F2APSQ03\dev2012;trusted_connection=yes'', ''SELECT * FROM DWReference.dbo.' + @TableName + ''')

	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'sitTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'sitTable
	END
	SELECT ' + @UniqName + ' AS ''' + @Name + ''', ' + @ID +'
	INTO #' + @TempTableName + 'sitTable
	FROM OPENROWSET(''SQLNCLI'', ''server=05W8F2APSQ03\sit2012;trusted_connection=yes'', ''SELECT * FROM DWReference.dbo.' + @TableName + ''')

	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'uatTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'uatTable
	END
	SELECT ' + @UniqName + ' AS ''' + @Name + ''', ' + @ID +'
	INTO #' + @TempTableName + 'uatTable
	FROM OPENROWSET(''SQLNCLI'', ''server=05W8F2APSQ03;trusted_connection=yes'', ''SELECT * FROM DWReference.dbo.' + @TableName + ''')
	
	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'ProdTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'ProdTable
	END
	SELECT ' + @UniqName + ' AS ''' + @Name + ''', ' + @ID +'
	INTO #' + @TempTableName + 'ProdTable
	FROM OPENROWSET(''SQLNCLI'', ''server=60W8F5QVSQ01;trusted_connection=yes'', ''SELECT * FROM DWReference.dbo.' + @TableName + ''')
	
	SELECT DISTINCT un.' + @Name + '
	,d.' + @ID +' AS ''Dev''
	,s.' + @ID +' AS ''Sit''
	,u.' + @ID +' AS ''Uat''
	,p.' + @ID +' AS ''Prod''
	,CASE WHEN ((COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') )
	<> ( COALESCE(d.' + @ID +', ''-1'') + COALESCE(s.' + @ID +', ''-1'') + COALESCE(u.' + @ID +', ''-1'') + COALESCE(p.' + @ID +', ''-1'') )) THEN 1 ELSE 0 END AS ''Different''
	FROM 
		(
			SELECT ' + @Name + ' FROM #' + @TempTableName + 'DEVTable
			UNION SELECT ' + @Name + ' FROM #' + @TempTableName + 'SitTable
			UNION SELECT ' + @Name + ' FROM #' + @TempTableName + 'UATTable
			UNION SELECT ' + @Name + ' FROM #' + @TempTableName + 'ProdTable
		) un        
	LEFT JOIN #' + @TempTableName + 'DEVTable d ON d.' + @Name + ' = un.' + @Name + '
	LEFT JOIN #' + @TempTableName + 'SitTable s ON s.' + @Name + ' = un.' + @Name + '
	LEFT JOIN #' + @TempTableName + 'UATTable u ON u.' + @Name + ' = un.' + @Name + '
	LEFT JOIN #' + @TempTableName + 'ProdTable p ON p.' + @Name + ' = un.' + @Name + '
	'
	
	IF @OnlyDifferent = 1
	BEGIN
	SET @sql = @sql + '	WHERE ((COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') + COALESCE(d.' + @ID +', ''-1'') )
	<> ( COALESCE(d.' + @ID +', ''-1'') + COALESCE(s.' + @ID +', ''-1'') + COALESCE(u.' + @ID +', ''-1'') + COALESCE(p.' + @ID +', ''-1'') ))
	'
	END

	SET @sql = @sql + 'ORDER BY d.' + @ID +'

	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'DEVTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'DEVTable
	END
	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'SitTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'SitTable
	END
	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'UatTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'UatTable
	END
	IF OBJECT_ID(''tempdb..#' + @TempTableName + 'ProdTable'') IS NOT NULL
	BEGIN
				DROP TABLE #' + @TempTableName + 'ProdTable
	END
	'

	SET @sqlQuery = @sqlQuery + @sql

	DELETE
	FROM #CheckTable
	WHERE TableName = @TableName AND ID = @ID AND Name = @Name
	END

	IF OBJECT_ID('tempdb..#CheckTable') IS NOT NULL
	BEGIN
				DROP TABLE #CheckTable
	END
	--SET @sqlQuery = REPLACE(@sqlQuery, '''', '''''')
	EXEC [dbo].[LongPrintN] @sqlQuery
	EXEC sp_executesql @sqlQuery;
END