
/**************************************************************************************************************

Author		:	Preethi Khatore
Create date	:	2 Nov 2009
Description	:	To send the failed process summary message 

Altered		:	Dylan Harvey
Date		:	20120912
Description	:	Removed logic for 'WithOutCubeBuilt' and call new stored proc



**************************************************************************************************************/
CREATE  PROCEDURE [dbo].[sp_SendEmailFailedLogToday] 
	-- Add the parameters for the stored procedure here
	@RecipientEmail varchar(max) = 0,
	@SystemName varchar(max) = 0,
	@CubeBuiltStatus varchar(50) ='WithOutCubeBuilt'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  -- DECLARE	@RecipientEmail varchar(max) = 'Preethi.khatore@brightstarcorp.com'
	--DECLARE @SystemName varchar(max) = 'UAT Regional Distribution'
    
    DECLARE @SuccessMessage AS VARCHAR(MAX)
    DECLARE @LogQuery AS VARCHAR(MAX)
    DECLARE @BodyMessage AS VARCHAR(MAX)
    DECLARE @Importance AS VARCHAR(20)
    DECLARE @CubeBuiltcompletestatus AS VARCHAR(50) = @CubeBuiltStatus
    declare @count int
    
    DECLARE @ProfileName NVARCHAR(255)
	SELECT @ProfileName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'EmailProfileName'
    
     If @CubeBuiltcompletestatus='WithCubeBuiltCompleted'
    BEGIN
    SELECT @SuccessMessage = 
				CASE 
					WHEN COUNT(*) = 0 
					THEN @SystemName + ' Process Log Summary - No Error Found' 
					ELSE 'FAILURE '+@SystemName + ' Process Log Summary!' END,
		   @Importance =
				CASE 
					WHEN COUNT(*) > 0 
					THEN 'High' 
					ELSE 'Normal' END,
		   @BodyMessage	= 'Hi'+ CHAR(10) + CHAR(10) +
				'Please do not reply this email as it is auto generated from ' + @SystemName + ' system. If you have any questions with this email please contact ' + @SystemName + ' team.' + CHAR(10) + CHAR(10) +
				CASE
					WHEN COUNT(*) = 0 
					THEN 'Please ignore the attachment as there is no error found.'
					ELSE  'Please check the attachment file as there are errors found in ' + 	@SystemName
				END + CHAR(10) + CHAR(10)
    FROM vi_FailedLogToday
    
    SET @LogQuery =  'SET NOCOUNT ON; SELECT * FROM RegDistETLReference.dbo.vi_FailedLogToday'
    
   -- select @count=COUNT(*) from vi_FailedLogToday
    
     EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @ProfileName,
    @recipients = @RecipientEmail,
    @body = @BodyMessage,
    @query = @LogQuery ,
    @subject =@SuccessMessage,
    @Importance = @Importance,
    @attach_query_result_as_file = 1,
    @query_result_no_padding = 0

END
ELSE IF @CubeBuiltcompletestatus='WithOutCubeBuilt'
	----If @CubeBuiltcompletestatus='WithOutCubeBuilt'



	 --DH 20120912 Replaced with new stored proc

	 BEGIN
	   SELECT @SuccessMessage = 
				CASE 
					WHEN COUNT(*) = 0 
					THEN @SystemName + ' Process Log Summary - No Error Found' 
					ELSE 'FAILURE '+@SystemName + ' Process Log Summary!' END,
		   @Importance =
				CASE 
					WHEN COUNT(*) > 0 
					THEN 'High' 
					ELSE 'Normal' END,
		   @BodyMessage	= 'Hi'+ CHAR(10) + CHAR(10) +
				'Please do not reply this email as it is auto generated from ' + @SystemName + ' system. If you have any questions with this email please contact ' + @SystemName + ' team.' + CHAR(10) + CHAR(10) +
				CASE
					WHEN COUNT(*) = 0 
					THEN 'Please ignore the attachment as there is no error found.'
					ELSE  'Please check the attachment file as there are errors found in ' + 	@SystemName
				END + CHAR(10) + CHAR(10)
	   FROM vi_FailedLogToday_Extractonly

	   SET @LogQuery =  'SET NOCOUNT ON; SELECT * FROM RegDistETLReference.dbo.vi_FailedLogToday_Extractonly'

	    select @count=COUNT(*)
	     from vi_FailedLogToday_Extractonly

	    --- Only if any error records exist
	    if @count>0


	   EXEC msdb.dbo.sp_send_dbmail
	   @profile_name = @ProfileName,
	   @recipients = @RecipientEmail,
	   @body = @BodyMessage,
	   @query = @LogQuery ,
	   @subject =@SuccessMessage,
	   @Importance = @Importance,
	   @attach_query_result_as_file = 1,
	   @query_result_no_padding = 0


	END
 ELSE 
	BEGIN 
	EXEC [spSendEmailExtractFailure] @RecipientEmail,	@SystemName ,'Now'
	END
END