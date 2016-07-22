
-- =============================================
-- Author:		Olof Szymczak
-- Create date: 16/12/2013
-- Description:	To send failed delivery message 
-- =============================================
CREATE PROCEDURE [dbo].[spSendEmailDeliveryFailure]
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
	SELECT @Email_Subject = '!!!Failure!!! - ' + @SystemName + ' Delivery Process Failed'
	SELECT @Importance = 'High'

	--Check if a process has failed and no action has been taken
	SELECT @count = COUNT (*)
	FROM [DeliveryControl] dc (NOLOCK)
	INNER JOIN  dbo.DeliveryExecutionlog dcl(nolock) ON dc.DeliveryControlID = dcl.DeliveryControlID
	WHERE  dcl.successflag =0 
	AND @LastErrorEmailChecker <= EndTime
	IF @count > 0
	BEGIN 
			SET @tableHTML =
			N'<H1>'+@SystemName+' Process Failure</H1>' +
			N'<font size = "3">Hi,<br>' + CHAR(10) + CHAR(10) +
			N'<br>Please check DWReference.' + CHAR(10) + CHAR(10) +
			N'<br>Please do not reply this email as it is auto generated from ' + @SystemName + 
			' system. If you have any questions with this email please contact ' + @SystemName + ' team.</font>'+
			N'<table border="1">' +
			N'<tr><th>DeliveryControlID</th>'+    
			N'<th>DeliveryPackageName</th>' +
			N'<th>Package failed date time</th>'+
			CAST ( ( 
			SELECT '#FF0000' AS [@bgcolor],
			td = DeliveryControlID, '',
			td = DeliveryPackageName, '',
			td = EndTime , ''
			FROM (	
					SELECT dc.DeliveryControlID, dc.DeliveryPackageName, MAX(EndTime) AS 'EndTime'
					FROM [DeliveryControl] dc (NOLOCK)
					INNER JOIN  dbo.DeliveryExecutionlog dcl(nolock) ON dc.DeliveryControlID = dcl.DeliveryControlID
					WHERE  dcl.successflag =0 
					AND @LastErrorEmailChecker <= EndTime
					GROUP BY dc.DeliveryControlID, dc.DeliveryPackageName
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
END