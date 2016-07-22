



CREATE PROCEDURE [dbo].[spUpdateDeliveryControlCurrentExtractJobID]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @FullExtractTable NVARCHAR(100)
	DECLARE @SqlQuery NVARCHAR(MAX)
	DECLARE @SourceControlID INT
	DECLARE @ExtractTable NVARCHAR(200)

	CREATE TABLE #TableMax (SourceControlID INT, ExtractTable VARCHAR(100), ExtractJobIDMax INT)

	DECLARE cur CURSOR FOR
	SELECT DISTINCT dc.SourceControlID, dc.ExtractTable, SUBSTRING(ss.ConfiguredValue, 
										CHARINDEX('Initial Catalog', ss.ConfiguredValue) + LEN('Initial CATALOG='), 
										CHARINDEX(';', ss.ConfiguredValue, CHARINDEX('Initial Catalog=', ss.ConfiguredValue))- (CHARINDEX('Initial Catalog=', ss.ConfiguredValue) + LEN('Initial CATALOG=')))
										collate DATABASE_DEFAULT + '.' + [ExtractTable]  AS 'FullExtractTable'
	FROM dbo.DeliveryControl dc
	INNER JOIN [dbo].SourceControl sc ON sc.SourceControlID = dc.SourceControlID
	INNER JOIN [dbo].SSISConfiguration ss ON sc.SSISConfigurationID = ss.SSISConfigurationID
	WHERE ss.ConfiguredValue LIKE '%Initial Catalog=%'

	OPEN cur
	FETCH NEXT FROM cur INTO @SourceControlID, @ExtractTable, @FullExtractTable
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @sqlQuery = 'INSERT #TableMax SELECT ' + CAST(@SourceControlID AS NVARCHAR(10)) + ', ''' + @ExtractTable + ''', MAX(ExtractJobID) FROM ' + @FullExtractTable
		PRINT @sqlQuery 
		EXEC sp_executesql @sqlQuery
		FETCH NEXT FROM cur INTO @SourceControlID, @ExtractTable, @FullExtractTable
	END
	CLOSE cur;
	DEALLOCATE cur;

------------------------------------------------------------------------------
-- 1.1 Update delivery control
------------------------------------------------------------------------------
	UPDATE [dbo].[DeliveryControl]
	SET [CurrentExtractJobID] = tm.ExtractJobIDMax 
	FROM [dbo].[DeliveryControl] dc
	INNER JOIN #TableMax tm ON dc.[ExtractTable] = tm.ExtractTable AND tm.SourceControlID = dc.SourceControlID
	WHERE ISNULL(dc.CurrentExtractJobID, -1) < tm.ExtractJobIDMax

	DROP TABLE #TableMax

------------------------------------------------------------------------------
-- 2.0 Return if there are any changes requiring Delivery manager to process.
------------------------------------------------------------------------------
	SELECT ISNULL(MAX(ABS([LastExtractJobID] - [CurrentExtractJobID])), 0) AS 'ChangesFound' FROM [dbo].[DeliveryControl] WHERE ISNULL(LastExtractJobID, -1) <> ISNULL(CurrentExtractJobID, -1)
END