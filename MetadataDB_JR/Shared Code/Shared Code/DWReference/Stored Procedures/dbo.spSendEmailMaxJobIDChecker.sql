-- =============================================
-- Author:		Nghi Ta
-- Create date: 25/6/2014
-- Description:	To send the failed for check max job id
-- =============================================
CREATE PROCEDURE [dbo].[spSendEmailMaxJobIDChecker]
  @EmailReceipent varchar(max) = 0
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

    DECLARE @Email_Subject NVARCHAR(255)
	DECLARE @contentHTML varchar(max) =''
	
	DECLARE @tableHTML TABLE
	(
		content varchar(max)
	)
   
    -- Set variables
	SELECT @ProfileName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'EmailProfileName'
	SELECT @SystemName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'SystemName'
	SELECT @Email_Subject = '!!!Failure!!! - ' + @SystemName + ' Check Max Job ID Process Failed'
	SELECT @Importance = 'High'

	--Check if a process has failed and no action has been taken
	INSERT @tableHTML EXECUTE dbo.spSendEmailExtractMaxJobIDFailure
	INSERT @tableHTML EXECUTE dbo.spSendEmailDeliveryMaxJobIDFailure
	INSERT @tableHTML EXECUTE dbo.spSendEmailSummaryMaxJobIDFailure
	
	IF( SELECT count(*) FROM @tableHTML) >0
		BEGIN 
				SET @contentHTML +=
						N'<H1>'+@SystemName+' Process Failure</H1>' +
						N'<font size = "3">Hi,<br>' + CHAR(10) + CHAR(10) +
						N'<br>Please check DWReference, the status is reporting that the packages below have failed.<br>  '+
						'This will need to be investigated.' + CHAR(10) + CHAR(10) +
						N'<br>Please do not reply this email as it is auto generated from ' + @SystemName + 
						' system. If you have any questions with this email please contact ' + @SystemName + ' team.</font>'

				SELECT @contentHTML = @contentHTML + content +'<br>' FROM @tableHTML

						EXEC	msdb.dbo.sp_send_dbmail
						@profile_name = @ProfileName,
						@recipients = @EmailReceipent,
						@body = @contentHTML,					
						@body_format = 'HTML', 
						@query = @LogQuery ,
						@subject =@Email_Subject,
						@Importance = @Importance
		END 
END
