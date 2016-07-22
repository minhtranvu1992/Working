


-- =============================================
-- Author:		Dylan Harvey
-- Create date: 21/12/2012
-- Description:	Send an email if process is hanging
--				send on every 24 hours and one on a daily schedule
-- =============================================
 CREATE PROCEDURE [dbo].[spSendEmailProcessHanging] 
	-- Add the parameters for the stored procedure here
	@EmailReceipent varchar(max) = 0,
	@ScheduleType AS VARCHAR (50)

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
   
	DECLARE @Message AS VARCHAR(MAX)
	DECLARE @LogQuery AS VARCHAR(MAX)
	DECLARE @BodyMessage AS VARCHAR(MAX)
	DECLARE @Importance AS VARCHAR(20)
	DECLARE @count INT
	DECLARE @ProfileName NVARCHAR(255)
    DECLARE @tableHTML  NVARCHAR(MAX) 
    DECLARE @Email_Subject NVARCHAR(255)
	DECLARE @SystemName NVARCHAR(255)
    
    -- Set variables
	SELECT @ProfileName =  ConfiguredValue 	FROM SSISConfiguration 	WHERE ConfigurationFilter = 'EmailProfileName'
	SELECT @SystemName = ConfiguredValue FROM SSISConfiguration 	WHERE ConfigurationFilter = 'SystemName'
	SELECT @Email_Subject = '!!!Failure!!! - ' + @SystemName + ' Process hanging'
	SELECT @Importance = 'High'
    
    
	IF @ScheduleType = 'Daily'    
	-- Only run once per day, do not check if an email has been sent
	BEGIN 
		-- Check if processes are taking longer than alocated time
		SELECT @count = COUNT(*) 
		FROM (
		SELECT  SuiteName AS NAME,'Suite' AS [Table]
		FROM Suite
		WHERE Status = 'P'
		AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
		UNION ALL
		SELECT ExtractPackageName AS NAME, 'ExtractControl' AS [Table]
		FROM ExtractControl 
		WHERE Status = 'P'
		AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
		)a
			
			IF @count > 0
			BEGIN
			
				-- Send email if a process is reporting to be hanging
					SET @tableHTML =
					N'<H1>'+@SystemName+' Process Hanging Report</H4>' +
					N'<font size = "3">Hi,<br>'+ CHAR(10) + CHAR(10) +
					N'<br>Please check DWReference, the status is reporting that the tables below with the associated packages'+ 
					' have been running longer that the allocated time. '+
					'The package might have finished and not have had the status updated.<br> This will need to be investigated.'+ CHAR(10) + CHAR(10) +
					N'<br>Please do not reply this email as it is auto generated from ' + @SystemName + 
					' system. If you have any questions with this email please contact ' + @SystemName + ' team.</font>'+
					N'<table border="1">' +
					N'<tr><th>Package Name</th>'+    
					N'<th>Table Name</th>' +
					N'<th>Status Change Date Time</th>'+
					CAST ( ( 
					SELECT td = [NAME], '',
					td = [Table], '',
					td = [StatusChangeDateTime] , ''
					FROM (
							SELECT  SuiteName AS [NAME],'Suite' AS [Table], [StatusChangeDateTime]
							FROM Suite
							WHERE Status = 'P'
							AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
							UNION ALL
							SELECT ExtractPackageName AS [NAME], 'ExtractControl' AS [Table], [StatusChangeDateTime]
							FROM ExtractControl 
							WHERE Status = 'P'
							AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
							)a
							 FOR XML PATH('tr'), TYPE 
					) AS NVARCHAR(MAX) ) +
					N'</table>' ;
					
				EXEC msdb.dbo.sp_send_dbmail @recipients='dylan.harvey@brightstarcorp.com',
					@subject = @Email_Subject,
					@body = @tableHTML,
					@profile_name = @ProfileName,
					@body_format = 'HTML', 
					@Importance = @Importance;
			END
				
	END
	-- Run every hour, only send emails where one has not been sent by the hourly process
	ELSE IF	@ScheduleType = 'Hourly'	
	BEGIN
			-- Check if processes are taking longer than alocated time
			SELECT @count = COUNT(*) 
			FROM (
			SELECT  SuiteName AS NAME,'Suite' AS [Table]
			FROM Suite
			WHERE Status = 'P'
			AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
			AND MaxExpectedExecutionEmailSent IS NULL
			UNION ALL
			SELECT ExtractPackageName AS NAME, 'ExtractControl' AS [Table]
			FROM ExtractControl 
			WHERE Status = 'P'
			AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
			AND MaxExpectedExecutionEmailSent IS NULL
			)a			
				IF @count > 0
				BEGIN			
					-- Send email if a process is reporting to be hanging
						SET @tableHTML =
						N'<H1>'+@SystemName+' Process Hanging Report</H4>' +
						N'<font size = "3">Hi,<br>'+ CHAR(10) + CHAR(10) +
						N'<br>Please check DWReference, the status is reporting that the tables below with the associated packages'+ 
						' have been running longer that the allocated time. '+
						'The package might have finished and not have had the status updated.<br> This will need to be investigated.'+ CHAR(10) + CHAR(10) +
						N'<br>Please do not reply this email as it is auto generated from ' + @SystemName + 
						' system. If you have any questions with this email please contact ' + @SystemName + ' team.</font>'+
						N'<table border="1">' +
						N'<tr><th>Package Name</th>'+    
						N'<th>Table Name</th>' +
						N'<th>Status Change Date Time</th>'+
						CAST ( ( 
						SELECT td = [NAME], '',
						td = [Table], '',
						td = [StatusChangeDateTime] , ''
						FROM (
								SELECT  SuiteName AS [NAME],'Suite' AS [Table], [StatusChangeDateTime]
								FROM Suite
								WHERE Status = 'P'
								AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
								AND MaxExpectedExecutionEmailSent IS NULL
								UNION ALL
								SELECT ExtractPackageName AS [NAME], 'ExtractControl' AS [Table], [StatusChangeDateTime]
								FROM ExtractControl 
								WHERE Status = 'P'
								AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
								AND MaxExpectedExecutionEmailSent IS NULL
								)a
								 FOR XML PATH('tr'), TYPE 
						) AS NVARCHAR(MAX) ) +
						N'</table>' ;
						
					EXEC msdb.dbo.sp_send_dbmail 
						@recipients = @EmailReceipent,
						@subject = @Email_Subject,
						@body = @tableHTML,
						@profile_name = @ProfileName,
						@body_format = 'HTML', 
						@Importance = @Importance ;
				
					-- Update sent email date for extract control and suite
					UPDATE [ExtractControl] 
					SET [MaxExpectedExecutionEmailSent] = GETDATE()
					WHERE Status = 'P' 	
					AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
					AND MaxExpectedExecutionEmailSent IS NULL
										
					UPDATE Suite
					SET [MaxExpectedExecutionEmailSent] = GETDATE()
					WHERE Status = 'P'
					AND StatusChangeDateTime + CAST(MaxExpectedExecutionDuration AS datetime) < GETDATE()
					AND MaxExpectedExecutionEmailSent IS NULL
				END				
	END
END
