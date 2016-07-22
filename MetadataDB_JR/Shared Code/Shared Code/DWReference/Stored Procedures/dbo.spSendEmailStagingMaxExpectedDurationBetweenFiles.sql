
-- =============================================
-- Author:		Nghi Ta
-- Create date: 1/7/2014
-- Description:	To send email notify staging manager has not found any file to execute
-- =============================================
CREATE PROCEDURE [dbo].[spSendEmailStagingMaxExpectedDurationBetweenFiles]
  @EmailReceipent varchar(max) = 0,
  @LastErrorEmailChecker DATETIME
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @Message AS VARCHAR(MAX)
	DECLARE @LogQuery AS VARCHAR(MAX)
	DECLARE @BodyMessage AS VARCHAR(MAX)
	DECLARE @Importance AS VARCHAR(20)
	DECLARE @count int    
	DECLARE @ProfileName NVARCHAR(255)
	DECLARE @SystemName varchar(max)
	DECLARE @tableHTML  NVARCHAR(MAX) 
    DECLARE @Email_Subject NVARCHAR(255)
    
    -- Set variables
	SELECT @ProfileName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'EmailProfileName'
	SELECT @SystemName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'SystemName'
	SELECT @Email_Subject = '!!!Failure!!! - ' + @SystemName + ' Checking Staging Max Expected Duration Between Files Failed'
	SELECT @Importance = 'High'

	--Check if a process has failed and no action has been taken
	
	SELECT @count = COUNT (*)
	FROM dbo.StagingControl 
		WHERE  LastProcessedTime >= @LastErrorEmailChecker
		AND (LastProcessedTime + CONVERT(DATETIME, MaxExpectedDurationBetweenFiles)) < GETDATE()

	IF @count > 0
	BEGIN 
			SET @tableHTML =
			N'<H1>'+@SystemName+' Process Failure</H1>' +
			N'<font size = "3">Hi,<br>' + CHAR(10) + CHAR(10) +
			N'<br>Please check DWReference, the status is reporting that the packages below have failed.<br>  '+
			'This will need to be investigated.' + CHAR(10) + CHAR(10) +
			N'<br>Please do not reply this email as it is auto generated from ' + @SystemName + 
			' system. If you have any questions with this email please contact ' + @SystemName + ' team.</font>'+
			N'<table border="1">' +
			N'<tr><th>Staging Control ID</th>'+    
			N'<th>Suite Name</th>' +
			N'<th>Staging Package Name</th>' +
			N'<th>Status</th>' +
			N'<th>Status Change Date Time</th>' +
			N'<th>Last Processed Time</th>' +
			N'<th>Max Expected Duration Between Files</th>' +
			N'<th>Expected Next Execution Time</th>' +
			CAST ( ( 
			SELECT  '#F7FE2E' AS [@bgcolor],
			td = StagingControlID, '',
			td = SuiteName, '',
			td = StagingPackageName, '',
			td = Status, '',
			td = StatusChangeDateTime, '',
			td = LastProcessedTime, '',
			td = MaxExpectedDurationBetweenFiles, '',
			td = ExpectedNextExecutionTime, ''
			FROM (	
					SELECT sc.StagingControlID, 
							s.SuiteName,
							sc.StagingPackageName,
							sc.Status,
							sc.StatusChangeDateTime,
							sc.LastProcessedTime,
							sc.MaxExpectedDurationBetweenFiles,
							(sc.LastProcessedTime + CONVERT(DATETIME, sc.MaxExpectedDurationBetweenFiles)) AS ExpectedNextExecutionTime
							FROM dbo.StagingControl sc
							INNER JOIN dbo.Suite s
							ON s.SuiteID = sc.SuiteID
							WHERE  sc.LastProcessedTime >= @LastErrorEmailChecker
							AND (LastProcessedTime + CONVERT(DATETIME,MaxExpectedDurationBetweenFiles)) < GETDATE()
				)a
					FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) ) +
			N'</table>
<br>Legend
<table border="1">
	<tr>
		<th>Colour</th>  
		<th>Description</th>
	</tr>
	<tr><td bgcolor="#F7FE2E"></td><td>This is a warning that the staging manager cannot execute file on expected time</td></tr>
</table>'

			BEGIN
					EXEC	msdb.dbo.sp_send_dbmail
					@profile_name = @ProfileName,
					@recipients = @EmailReceipent,
					@body = @tableHTML,					
					@body_format = 'HTML', 
					@query = @LogQuery ,
					@subject =@Email_Subject,
					@Importance = @Importance
			END				
			
		END 			    
			
		-- Update max expected execution email sent
		UPDATE [StagingControl] 
		SET [MaxExpectedExecutionEmailSent] = GETDATE()
		WHERE  LastProcessedTime >= @LastErrorEmailChecker
		AND (LastProcessedTime + CONVERT(DATETIME, MaxExpectedDurationBetweenFiles)) < GETDATE()
END


