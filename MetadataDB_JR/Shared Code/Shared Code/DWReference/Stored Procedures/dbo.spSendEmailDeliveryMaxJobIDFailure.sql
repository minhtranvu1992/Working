

-- ================================================================================
-- Author:		Nghi Ta
-- Create date: 26/6/2014
-- Description:	To send the failed for check max job id in base layer 
-- History:     
--         Modified By               Modified Date           Reason of Changes
--         Nghi Ta                   2014-7-15               Remove hardcode database name
-- ================================================================================
CREATE PROCEDURE [dbo].[spSendEmailDeliveryMaxJobIDFailure]
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @jobName nvarchar(20)
DECLARE @databaseName nvarchar(20)=''
DECLARE @tableName nvarchar(100)
DECLARE @ETLDeliveryJobId int
DECLARE @ETLExtractJobId int
DECLARE @deliveryTableHTML  varchar(max)=''

DECLARE @DeliveryErrorTable TABLE
(
    DataLayer nvarchar(20),
	TableName nvarchar(100),
	MaxDeliveryJobID int,
	ETLParameterDeliveryJobId int,
	ETLParameterExtractJobId int,
	DeliveryControlId int,
	DeliveryPackageName varchar(200),
	LastDeliveryJobId int,
	LastExtractJobID int,
	CurrentExtractJobID int
)

SET @jobName ='DeliveryJobID' 

SELECT @databaseName =  SUBSTRING(ss.ConfiguredValue, 
										CHARINDEX('Initial Catalog', ss.ConfiguredValue) + LEN('Initial CATALOG='), 
										CHARINDEX(';', ss.ConfiguredValue, CHARINDEX('Initial Catalog=', ss.ConfiguredValue))- (CHARINDEX('Initial Catalog=', ss.ConfiguredValue) + LEN('Initial CATALOG=')))
										collate DATABASE_DEFAULT 
	FROM  [dbo].SSISConfiguration ss 
	WHERE  ss.ConfigurationFilter = 'ConnStr_DWData_DB'

-- Get Delivery Job Id from ETLParameters
SELECT @ETLDeliveryJobId = ETLParameterValue FROM dbo.ETLParameters 
WHERE ETLParameterName =  @jobName
SELECT @ETLExtractJobId = ETLParameterValue FROM dbo.ETLParameters 
WHERE ETLParameterName =  'ExtractJobID'


DECLARE cur CURSOR FOR 
	SELECT DISTINCT  dc.DeliveryTable FROM dbo.DeliveryControl dc
	WHERE dc.DeliveryTable IS NOT NULL

	OPEN cur
	FETCH NEXT FROM cur
	   INTO  @tableName
 
	WHILE @@FETCH_STATUS = 0
 
	BEGIN

			DECLARE @fullTable nvarchar(300) = @databaseName+'.'+@tableName
			DECLARE @sql nvarchar(max)=''
			DECLARE @maxDeliveryJobId int 
			DECLARE @lastDeliveryJobId int
		    
			SET @sql = ' SELECT @maxDeliveryJobId = ISNULL(MAX('+@jobName+'),0) FROM ' + @fullTable
			
			Exec sp_executesql @sql,  N'@maxDeliveryJobId int OUTPUT',  @maxDeliveryJobId = @maxDeliveryJobId OUTPUT;

			IF @maxDeliveryJobId > @ETLDeliveryJobId
			BEGIN
				INSERT INTO @DeliveryErrorTable
				(
					DataLayer,
					TableName,
					MaxDeliveryJobID,
					ETLParameterDeliveryJobId
				)
				VALUES
				(
					@databaseName,
					@tableName,
					@maxDeliveryJobId,
					@ETLDeliveryJobId
				)
		
			END 

	   FETCH NEXT FROM cur
	   INTO  @tableName
	END
 
	CLOSE cur 
	DEALLOCATE cur 

DECLARE @count int
DECLARE @countAllError int
 SELECT @count = count(*)
			       FROM dbo.DeliveryControl d
			       WHERE LastDeliveryJobID > @ETLDeliveryJobId 
										    OR LastExtractJobID > @ETLExtractJobId
											OR CurrentExtractJobID > @ETLExtractJobId
    IF @count >0
		BEGIN
			INSERT INTO @DeliveryErrorTable
			(
			   ETLParameterDeliveryJobId,
			   ETLParameterExtractJobId,
				DeliveryControlId,
				DeliveryPackageName,
				LastDeliveryJobId,
				LastExtractJobID,
				CurrentExtractJobID
			)
			
			 SELECT @ETLDeliveryJobId, @ETLExtractJobId, DeliveryControlId, DeliveryPackageName, LastDeliveryJobId, LastExtractJobID, CurrentExtractJobID 
			       FROM dbo.DeliveryControl d
			       WHERE LastDeliveryJobID > @ETLDeliveryJobId 
										    OR LastExtractJobID > @ETLExtractJobId
											OR CurrentExtractJobID > @ETLExtractJobId

		END 

  SELECT @countAllError = count(*) FROM @DeliveryErrorTable
  IF @countAllError >0
		BEGIN
		-- Convert error table to HTML format
		DECLARE @SystemName varchar(200)

					SELECT @SystemName = ConfiguredValue 
					FROM SSISConfiguration 
					WHERE ConfigurationFilter = 'SystemName'	
		
		SET @deliveryTableHTML += 
						N'<h2> DELIVERY MANAGER </h2>' 
      
	    IF (SELECT count(*) FROM  @DeliveryErrorTable WHERE DataLayer IS NOT NULL) >0
				BEGIN
					SET @deliveryTableHTML += 
						N'<h2> Base Layer </h2>' +
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
						td = MaxDeliveryJobID , '',
						td = ETLParameterDeliveryJobId, '',
						td = IssueDesc, ''
						FROM (	
								SELECT DataLayer, 
									TableName, 
									MaxDeliveryJobID,
									ETLParameterDeliveryJobId, 
									'Table: '+ TableName +' has max DeliveryJobID: '+ convert(varchar,MaxDeliveryJobID)+'  is greater than  DeliveryJobID in ETLParameters: '+ convert(varchar,ETLParameterDeliveryJobId) AS IssueDesc
									 FROM  @DeliveryErrorTable
									WHERE DataLayer IS NOT NULL
							)a
								FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>'
				END


	       IF (SELECT count(*) FROM  @DeliveryErrorTable WHERE DeliveryControlId IS NOT NULL) >0
				BEGIN
				   SET @deliveryTableHTML +=
						N'<h2>ETL Reference Delivery Control </h2>' +
						N'<table border="1">' +
						N'<th width="100">Delivery Control Id</th>' +
						N'<th width="150">Delivery Package Name</th>' +
						N'<th width="100">Last Delivery Job Id</th>'+
						N'<th width="100">Last Extract Job Id</th>'+
						N'<th width="100">Current Extract Job ID</th>'+
						N'<th width="100">ETL Delivery Job Id</th>'+  
						N'<th width="100">ETL Extract Job Id</th>'+
						N'<th width="200">Issue Desc</th>'+
						CAST ( ( 
						SELECT '#F7FE2E'  AS [@bgcolor],
						td = DeliveryControlId, '',
						td = DeliveryPackageName, '',
						td = LastDeliveryJobId, '',
						td = LastExtractJobId , '',
						td = CurrentExtractJobID , '',
						td = ETLParameterDeliveryJobId , '',
						td = ETLParameterExtractJobId, '',
						td = IssueDesc, ''
						FROM (	
								SELECT DeliveryControlId,
									DeliveryPackageName,
									LastDeliveryJobId,
									LastExtractJobId,
									CurrentExtractJobID,
									ETLParameterDeliveryJobId,
									ETLParameterExtractJobId,
									 CASE WHEN LastDeliveryJobId > ETLParameterDeliveryJobId
									      THEN 'DeliveryControlID: '+convert(varchar,DeliveryControlId)+' has LastDeliveryJobId: '+convert(varchar,LastDeliveryJobId)+' is greater than DeliveryJobId in ETLParameters: '+ convert(varchar,ETLParameterDeliveryJobId)
									 	  WHEN LastExtractJobId > ETLParameterExtractJobId
									      THEN 'DeliveryControlID: '+convert(varchar,DeliveryControlId)+' has LastExtractJobId: '+convert(varchar,LastExtractJobId)+' is greater than ExtractJobId in ETLParameters: '+ convert(varchar,ETLParameterExtractJobId)
										  WHEN CurrentExtractJobID > ETLParameterExtractJobId
									      THEN 'DeliveryControlID: '+convert(varchar,DeliveryControlId)+' has CurrentExtractJobID: '+convert(varchar,CurrentExtractJobID)+' is greater than  ExtractJobId in ETLParameters: '+ convert(varchar,ETLParameterExtractJobId)
									
									 ELSE '' END AS IssueDesc   
									FROM @DeliveryErrorTable
									WHERE DeliveryControlID IS NOT NULL
							)a
								FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>'
				END 
			set @deliveryTableHTML +=
							'<br>Legend
							<table border="1" style="border-style: solid">
								<tr>
									<th>Colour</th>  
									<th>Description</th>
								</tr>
								<tr><td bgcolor="#F7FE2E"></td><td>This is a warning that delivery manager can be failed because of getting wrong delivery job id</td></tr>
							</table>'


		-- Return extract table html
		SELECT @deliveryTableHTML
	END 

END
