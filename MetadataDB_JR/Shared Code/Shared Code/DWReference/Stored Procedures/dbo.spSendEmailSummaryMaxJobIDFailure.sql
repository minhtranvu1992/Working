
-- ===============================================================================
-- Author:		Nghi Ta
-- Create date: 26/6/2014
-- Description:	To send the failed for check max job id in logical layer 
-- History:     
--         Modified By               Modified Date           Reason of Changes
--         Nghi Ta                   2014-7-15               Remove hardcode database name
-- ================================================================================
CREATE PROCEDURE [dbo].[spSendEmailSummaryMaxJobIDFailure]
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @schemaName nvarchar(20)=''
DECLARE @tableName nvarchar(100)
DECLARE @ETLDeliveryJobId int
DECLARE @ETLSummaryJobId int
DECLARE @summaryTableHTML  varchar(max)=''

DECLARE @SummaryErrorTable TABLE
(
    ETLParameterSummaryJobId int,
	ETLParameterDeliveryJobId int,
	SummaryControlId int,
	SummaryPackageName varchar(200),
	LastSummaryJobId int,
	LastDeliveryJobId int,
	CurrentDeliveryJobId int
)


-- Get Summary Job Id from ETLParameters
SELECT @ETLSummaryJobId = ETLParameterValue FROM dbo.ETLParameters 
WHERE ETLParameterName =  'SummaryJobID'

-- Get Delivery Job Id from ETLParameters
SELECT @ETLDeliveryJobId = ETLParameterValue FROM dbo.ETLParameters 
WHERE ETLParameterName =  'DeliveryJobID'
DECLARE @count int


SELECT @count = count(*) FROM dbo.SummaryControl sc 
	WHERE LastSummaryJobID > @ETLSummaryJobId 
		OR LastDeliveryJobID > @ETLDeliveryJobId
		OR CurrentDeliveryJobID > @ETLDeliveryJobId

IF @count >0
BEGIN
	INSERT INTO @SummaryErrorTable
	(
		ETLParameterSummaryJobId,
		ETLParameterDeliveryJobId,
		SummaryControlId,
		SummaryPackageName,
		LastSummaryJobId,
		LastDeliveryJobId,
		CurrentDeliveryJobId
	)
			
		SELECT @ETLSummaryJobId,
			    @ETLDeliveryJobId,
				SummaryControlId,
				SummaryPackageName,
				LastSummaryJobId,
				LastDeliveryJobId,
				CurrentDeliveryJobID 
		FROM dbo.SummaryControl sc 
       		WHERE LastSummaryJobID > @ETLSummaryJobId 
			OR LastDeliveryJobID > @ETLDeliveryJobId
			OR CurrentDeliveryJobID > @ETLDeliveryJobId

	
 DECLARE @SystemName varchar(200)

				SELECT @SystemName = ConfiguredValue 
				FROM SSISConfiguration 
				WHERE ConfigurationFilter = 'SystemName'	
		
 SET @summaryTableHTML += 
				N'<h2> SUMMARY MANAGER </h2>' 

				SET @summaryTableHTML +=
					N'<h2>ETL Reference Summary Control </h2>' +
					N'<table border="1">' +
					N'<th width="100">Summary Control Id</th>' +
					N'<th width="150">Summary Package Name</th>' +
					N'<th width="100">Last Summary Job Id</th>'+
					N'<th width="100">Last Delivery Job Id</th>'+
					N'<th width="100">Current Delivery Job ID</th>'+
					N'<th width="100">ETL Summary Job Id</th>'+  
					N'<th width="100">ETL Delivery Job Id</th>'+
					N'<th width="200">Issue Desc</th>'+
					CAST ( ( 
					SELECT '#F7FE2E'  AS [@bgcolor],
					td = SummaryControlId, '',
					td = SummaryPackageName, '',
					td = LastSummaryJobId, '',
					td = LastDeliveryJobId , '',
					td = CurrentDeliveryJobID , '',
					td = ETLParameterSummaryJobId, '',
					td = ETLParameterDeliveryJobId , '',
					td = IssueDesc, ''
					FROM (	
							SELECT SummaryControlId,
								SummaryPackageName,
								ISNULL(LastDeliveryJobId,'') AS LastDeliveryJobId,
								ISNULL(LastSummaryJobId,'') AS LastSummaryJobId,
								ISNULL(CurrentDeliveryJobID,'') AS CurrentDeliveryJobID,
								ETLParameterSummaryJobId,
								ETLParameterDeliveryJobId,
									CASE WHEN LastSummaryJobId > ETLParameterSummaryJobId
										THEN 'SummaryControlID: '+convert(varchar,SummaryControlId)+' has LastSummaryJobId: '+convert(varchar,LastSummaryJobId)+' is greater than SummaryJobId in ETLParameters: '+ convert(varchar,ETLParameterSummaryJobId)
									 	WHEN LastDeliveryJobId > ETLParameterDeliveryJobId
										THEN 'SummaryControlID: '+convert(varchar,SummaryControlId)+' has LastDeliveryJobId: '+convert(varchar,LastDeliveryJobId)+' is greater than DeliveryJobId in ETLParameters: '+ convert(varchar,ETLParameterDeliveryJobId)
										WHEN CurrentDeliveryJobID > ETLParameterDeliveryJobId
										THEN 'SummaryControlID: '+convert(varchar,SummaryControlId)+' has CurrentDeliveryJobID: '+convert(varchar,CurrentDeliveryJobID)+' is greater than DeliveryJobId in ETLParameters: '+ convert(varchar,ETLParameterDeliveryJobId)
									
									ELSE '' END AS IssueDesc   
								FROM @SummaryErrorTable
								WHERE SummaryControlId IS NOT NULL
						)a
							FOR XML PATH('tr'), TYPE 
					) AS NVARCHAR(MAX) ) +
					N'</table>'

					set @summaryTableHTML +=
					'<br>Legend
					<table border="1" style="border-style: solid">
						<tr>
							<th>Colour</th>  
							<th>Description</th>
						</tr>
						<tr><td bgcolor="#F7FE2E"></td><td>This is a warning that summary manager can be failed because of getting wrong summary job id</td></tr>
					</table>'


	-- Return extract table html
	SELECT @summaryTableHTML
END 
	

END
