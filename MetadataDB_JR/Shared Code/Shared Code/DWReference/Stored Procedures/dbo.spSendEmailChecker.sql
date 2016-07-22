
-- =============================================
-- Author:		Olof Szymczak
-- Create date: 16/12/2013
-- Description:	To send failed message 
-- =============================================
CREATE PROCEDURE [dbo].[spSendEmailChecker] 
  @ScheduleType NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ETLParameterName NVARCHAR(50)
	DECLARE @ScheduleID INT
	DECLARE @ScheduleName NVARCHAR(100)  
	DECLARE @LastErrorEmailChecker DATETIME
	DECLARE @EmailReceipent NVARCHAR(255)
    
	IF @ScheduleType = 'Daily'
	BEGIN
		SET @ScheduleName = 'ErrorEmailCheckDaily'
		SET @ETLParameterName = 'LastErrorDailyEmailChecker'
	END
	ELSE 
	BEGIN 
		SET @ScheduleName = 'ErrorEmailCheckHourly'
		SET @ETLParameterName = 'LastErrorHourlyEmailChecker'
	END

	SELECT @ScheduleID = [ScheduleID] FROM [dbo].[Schedule] WHERE ScheduleName = @ScheduleName
	
	SELECT @LastErrorEmailChecker = [ETLParameterValue] FROM [dbo].[ETLParameters] WHERE [ETLParameterName] = @ETLParameterName
	
	SELECT @EmailReceipent = [ConfiguredValue] FROM [dbo].[SSISConfiguration] WHERE [ConfigurationFilter] = 'EmailReceipent'
	
	EXEC [dbo].[spSendEmailStagingFailure] @EmailReceipent = @EmailReceipent, @LastErrorEmailChecker = @LastErrorEmailChecker, @ScheduleType = @ScheduleType
	EXEC [dbo].[spSendEmailExtractFailure] @EmailReceipent = @EmailReceipent, @LastErrorEmailChecker = @LastErrorEmailChecker, @ScheduleType = @ScheduleType
	EXEC [dbo].[spSendEmailProcessHanging] @EmailReceipent = @EmailReceipent, @ScheduleType = @ScheduleType
	EXEC [dbo].[spSendEmailDeliveryFailure]  @EmailReceipent = @EmailReceipent, @LastErrorEmailChecker = @LastErrorEmailChecker, @ScheduleType = @ScheduleType
	EXEC [dbo].[spSendEmailSummaryFailure]  @EmailReceipent = @EmailReceipent, @LastErrorEmailChecker = @LastErrorEmailChecker, @ScheduleType = @ScheduleType
	EXEC [dbo].[spSendEmailMaxJobIDChecker] @EmailReceipent = @EmailReceipent
	EXEC [dbo].[spSendEmailStagingMaxExpectedDurationBetweenFiles]  @EmailReceipent = @EmailReceipent, @LastErrorEmailChecker = @LastErrorEmailChecker

	UPDATE [dbo].[ETLParameters] SET [ETLParameterValue]  = GETDATE() WHERE [ETLParameterName] = @ETLParameterName
END