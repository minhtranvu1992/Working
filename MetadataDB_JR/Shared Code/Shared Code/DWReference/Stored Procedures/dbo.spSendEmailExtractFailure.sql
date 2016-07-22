-- =============================================
-- Author:		Dylan Harvey/Olof Szymczak
-- Create date: 16/12/2013
-- Description:	To send the failed extract message 
-- =============================================
CREATE PROCEDURE [dbo].[spSendEmailExtractFailure]
  @EmailReceipent varchar(max) = 0,
  @LastErrorEmailChecker DATETIME,
  @ScheduleType NVARCHAR(100)
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
	SELECT @Email_Subject = '!!!Failure!!! - ' + @SystemName + ' Extract Process Failed'
	SELECT @Importance = 'High'

	--Check if a process has failed and no action has been taken
	SELECT @count = COUNT (*)
	FROM [ExtractControl] ec (NOLOCK)
					INNER JOIN  dbo.ExtractExecutionlog ecl(nolock) ON ec.ExtractControlID = ecl.ExtractControlID
					WHERE  (ecl.successflag =0 
					AND @LastErrorEmailChecker <= EndTime)
					OR ((ec.Status = 'F' AND [FailedCountEmailSent] IS NULL) -- handle hourly
                    OR (ec.Status = 'F' AND @ScheduleType = 'Daily'))

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
			N'<tr><th>ExtractControlID</th>'+    
			N'<th>SuiteName</th>' +
			N'<th>ExtractPackageName</th>' +
			N'<th>Last Status Change date time</th>'+
			N'<th>Last Package failed date time</th>'+
			N'<th>Package Status</th>'+
			N'<th>Failed Count</th>'+
			CAST ( ( 
			SELECT  CASE WHEN Status = 'F' THEN '#FF0000' 
			             ELSE '#F7FE2E'
			END AS [@bgcolor],
			td = ExtractControlID, '',
			td = SuiteName, '',
			td = ExtractPackageName, '',
			td = [StatusChangeDateTime] , '',
			td = [EndTime], '',
			td = [status] , '',
			td =  FailedCount , ''
			FROM (	
					SELECT ec.ExtractControlID,ec.ExtractPackageName, ec.[StatusChangeDateTime], MAX(ecl.EndTime) AS 'EndTime', ec.[status], ISNULL(ec.FailedCount,0) AS FailedCount, s.SuiteName
					FROM [ExtractControl] ec (NOLOCK)
					INNER JOIN dbo.Suite s (NOLOCK) ON s.SuiteID = ec.SuiteID
					INNER JOIN  dbo.ExtractExecutionlog ecl(nolock) ON ec.ExtractControlID = ecl.ExtractControlID
					WHERE  (ecl.successflag =0 
					AND @LastErrorEmailChecker <= EndTime)
					OR (ec.Status = 'F' AND [FailedCountEmailSent] IS NULL) -- handle hourly
					OR (ec.Status = 'F' AND @ScheduleType = 'Daily')
					GROUP BY ec.ExtractControlID,ec.ExtractPackageName, ec.[StatusChangeDateTime], ec.[status], ISNULL(ec.FailedCount,0), s.SuiteName
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
	<tr><td bgcolor="#FF0000"></td><td>The package has failed and will not work until an administrator resets the status</td></tr>
	<tr><td bgcolor="#F7FE2E"></td><td>This is a warning that the package has failed but will continue to work until it hits the max fail count</td></tr>
</table>'

			EXEC	msdb.dbo.sp_send_dbmail
			@profile_name = @ProfileName,
			@recipients = @EmailReceipent,
			@body = @tableHTML,					
			@body_format = 'HTML', 
			@query = @LogQuery ,
			@subject =@Email_Subject,
			@Importance = @Importance
					
		END 			    
			
		-- Update email sent time	
		UPDATE [ExtractControl] 
		SET [FailedCountEmailSent] = GETDATE()
		WHERE Status = 'F' 	
		AND [FailedCountEmailSent] IS NULL
END
