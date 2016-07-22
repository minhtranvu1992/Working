
-- ================================================================================
-- Author:		Nghi Ta
-- Create date: 25/6/2014
-- Description:	To send the failed for check max job id in extract layer 
-- History:     
--         Modified By               Modified Date           Reason of Changes
--         Nghi Ta                   2014-7-15               Remove hardcode database name
-- ================================================================================
CREATE PROCEDURE [dbo].[spSendEmailExtractMaxJobIDFailure]
AS
BEGIN
	SET NOCOUNT ON;
	
DECLARE @jobName nvarchar(20)
DECLARE @databaseName nvarchar(200)
DECLARE @tableName nvarchar(200)
DECLARE @ETLExtractJobId int
DECLARE @extractTableHTML  varchar(max)=''

DECLARE @ExtErrorTable TABLE
(
    DataLayer nvarchar(20),
	TableName nvarchar(200),
	MaxExtractJobID int,
	ETLParameterExtractJobId int,
	ExtractControlId int,
	ExtractPackageName varchar(200),
	LastExtractJobId int
)

SET @jobName ='ExtractJobID' 

-- Get Extract Job Id from ETLParameters
SELECT @ETLExtractJobId = ETLParameterValue FROM dbo.ETLParameters 
WHERE ETLParameterName =  @jobName



	DECLARE cur CURSOR FOR 
	SELECT DISTINCT 
		SUBSTRING(ss.ConfiguredValue, 
											CHARINDEX('Initial Catalog', ss.ConfiguredValue) + LEN('Initial CATALOG='), 
											CHARINDEX(';', ss.ConfiguredValue, CHARINDEX('Initial Catalog=', ss.ConfiguredValue))- (CHARINDEX('Initial Catalog=', ss.ConfiguredValue) + LEN('Initial CATALOG='))) collate DATABASE_DEFAULT AS DatabaseName
		,[ExtractTable]  AS 'FullExtractTable'
		FROM dbo.ExtractControl ec
		INNER JOIN [dbo].SourceControl sc ON sc.SourceControlID = ec.DestinationControlID
		INNER JOIN [dbo].SSISConfiguration ss ON sc.SSISConfigurationID = ss.SSISConfigurationID
		WHERE ss.ConfiguredValue LIKE '%Initial Catalog=%' AND ec.ExtractTable IS NOT NULL

	OPEN cur
	FETCH NEXT FROM cur INTO @databaseName, @tableName
	WHILE (@@FETCH_STATUS = 0)

		BEGIN

			DECLARE @sql nvarchar(max)
			DECLARE @isExistExtractJobID int
			DECLARE @fullExtractTable nvarchar(200) = @databaseName+'.'+@tableName
			
			SET @sql = ' SELECT @isExistExtractJobID = count(*)  FROM '+@databaseName+'.INFORMATION_SCHEMA.COLUMNS c
						WHERE c.COLUMN_NAME ='''+@jobName+''' AND  c.TABLE_CATALOG+''.''+c.TABLE_SCHEMA+''.''+c.TABLE_NAME  = REPLACE(REPLACE('''+@fullExtractTable+''',''['',''''),'']'','''')'

		
			Exec sp_executesql @sql,  N'@isExistExtractJobID int OUTPUT',  @isExistExtractJobID = @isExistExtractJobID OUTPUT;
		
			IF @isExistExtractJobID>0
			BEGIN
				DECLARE @maxExtractJobId int
				DECLARE @lastExtractJobId int

			
				SET @sql = ' SELECT @maxExtractJobId = ISNULL(MAX('+@jobName+'),0) FROM '+ @fullExtractTable
		
				Exec sp_executesql @sql,  N'@maxExtractJobId int OUTPUT',  @maxExtractJobId = @maxExtractJobId OUTPUT;

				IF @maxExtractJobId > @ETLExtractJobId
				BEGIN
					INSERT INTO @ExtErrorTable
					(
						DataLayer,
						TableName,
						MaxExtractJobID,
						ETLParameterExtractJobId
					)
					VALUES
					(
						@databaseName,
						@tableName,
						@maxExtractJobId,
						@ETLExtractJobId
					)
		
				END 
			END 
			
	  	FETCH NEXT FROM cur INTO @databaseName, @tableName
	END
	
	CLOSE cur;
	DEALLOCATE cur;

DECLARE @count int
DECLARE @countAllError int
SELECT @count = COUNT(*) FROM dbo.ExtractControl 
				WHERE LastExtractJobID > @ETLExtractJobId
IF @count >0
		BEGIN
			INSERT INTO @ExtErrorTable
			(
			  ETLParameterExtractJobId,
				ExtractControlId,
				ExtractPackageName,
				LastExtractJobId
				
			)
			SELECT @ETLExtractJobId, ExtractControlId,ExtractPackageName,LastExtractJobId FROM dbo.ExtractControl 
				WHERE LastExtractJobID > @ETLExtractJobId

		END 

  SELECT @countAllError = count(*) FROM @ExtErrorTable
  IF @countAllError >0
		BEGIN
		-- Convert error table to HTML format
		DECLARE @SystemName varchar(200)

			SELECT @SystemName = ConfiguredValue 
			FROM SSISConfiguration 
			WHERE ConfigurationFilter = 'SystemName'	
 
		SET @extractTableHTML += 
					N'<h2> EXTRACT MANGER </h2>'

			   IF (SELECT count(*) FROM  @ExtErrorTable WHERE DataLayer IS NOT NULL) >0
						BEGIN
							SET @extractTableHTML += 
								N'<h2> Extract Layer </h2>' +
								N'<table border="1">' +
								N'<tr><th  width="100">Data Layer</th>'+    
								N'<th width="150">Table Name</th>' +
								N'<th  width="100">Max Etract Job ID</th>'+
								N'<th width="100">ETL Extract Job Id</th>'+
								N'<th  width="200">Issue Desc</th>'+
								CAST ( ( 
								SELECT '#F7FE2E'  AS [@bgcolor],
								td = DataLayer, '',
								td = TableName, '',
								td = MaxExtractJobID , '',
								td = ETLParameterExtractJobId, '',
								td = IssueDesc, ''
								FROM (	
										SELECT DataLayer, 
											TableName, 
											MaxExtractJobID,
											ETLParameterExtractJobId, 
											'Table: '+ TableName +' has max ExtractJobID: '+ convert(varchar,MaxExtractJobID)+'  is greater than  ExtractJobID in ETLParameters: '+ convert(varchar,ETLParameterExtractJobId) AS IssueDesc
											 FROM  @ExtErrorTable
											WHERE DataLayer IS NOT NULL
									)a
										FOR XML PATH('tr'), TYPE 
								) AS NVARCHAR(MAX) ) +
								N'</table>'
						END
				   IF (SELECT count(*) FROM  @ExtErrorTable WHERE ExtractControlId IS NOT NULL) >0
						BEGIN
						   SET @extractTableHTML +=
								N'<h2>ETL Reference Extract Control </h2>' +
								N'<table border="1">' +
								N'<th width="100">Extract Control Id</th>' +
								N'<th width="150">Extract Package Name</th>' +
								N'<th width="100">Last Extract Job Id</th>'+
								N'<th width="100">ETL Extract Job Id</th>'+  
								N'<th width="200">Issue Desc</th>'+
								CAST ( ( 
								SELECT '#F7FE2E'  AS [@bgcolor],
								td = ExtractControlId, '',
								td = ExtractPackageName, '',
								td = LastExtractJobId , '',
								td = ETLParameterExtractJobId, '',
								td = IssueDesc, ''
								FROM (	
										SELECT ExtractControlId,
											ExtractPackageName,
											LastExtractJobId,
											ETLParameterExtractJobId,
											 CASE WHEN LastExtractJobId > ETLParameterExtractJobId
												  THEN 'ExtractControlID: '+convert(varchar,ExtractControlId)+' has LastExtractJobId: '+convert(varchar,LastExtractJobId)+' is greater than  ExtractJobID in ETLParameters: '+ convert(varchar,ETLParameterExtractJobId)
											 ELSE '' END AS IssueDesc   
											FROM @ExtErrorTable
											WHERE ExtractControlId IS NOT NULL
									)a
										FOR XML PATH('tr'), TYPE 
								) AS NVARCHAR(MAX) ) +
								N'</table>'
						END 
					set @extractTableHTML +=
									'<br>Legend
									<table border="1" style="border-style: solid">
										<tr>
											<th>Colour</th>  
											<th>Description</th>
										</tr>
										<tr><td bgcolor="#F7FE2E"></td><td>This is a warning that extract manager can be failed because of getting wrong extract job id</td></tr>
									</table>'


		-- Return extract table html
		SELECT @extractTableHTML
		END
END
