
-- ==================================================================
-- Author:		Preethi Khatore
-- Create date: 01 Feb 2012
-- Description:	To send the Summary failed process summary message 
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_SendEmailSummaryFailedToday] 
	-- Add the parameters for the stored procedure here
	@RecipientEmail varchar(max) = 0,
	@SystemName varchar(max) = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
   --DECLARE	@RecipientEmail varchar(max) = 'Preethi.khatore@brightstarcorp.com'
	--DECLARE @SystemName varchar(max) = 'UAT Regional Distribution'
    
    DECLARE @SuccessMessage AS VARCHAR(MAX)
    DECLARE @LogQuery AS VARCHAR(MAX)
    DECLARE @BodyMessage AS VARCHAR(MAX)
    DECLARE @Importance AS VARCHAR(20)
    DECLARE @count int =1
    DECLARE @Currentcnt int =1
    
    while @count=@Currentcnt 
    BEGIN
    
    
    SELECT @SuccessMessage = 'Regional Distribution Summary Load Failed',			
		   @Importance = 'High',
		   @BodyMessage	= 'Hi'+ CHAR(10) + CHAR(10) +
				'Please do not reply this email as it is auto generated from ' + @SystemName + ' system. If you have any questions with this email please contact ' + @SystemName + ' team.' + CHAR(10) + CHAR(10) +
				 'Check the Summary load step in ' + 	@SystemName
				 + CHAR(10) + CHAR(10)
    
   -- SET @LogQuery =  'SET NOCOUNT ON; SELECT * FROM RegDistETLReference.dbo.vi_FailedLogToday'
    
    DECLARE @ProfileName NVARCHAR(255)
	SELECT @ProfileName = ConfiguredValue FROM SSISConfiguration WHERE ConfigurationFilter = 'EmailProfileName'
	
	EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @ProfileName,
    @recipients = @RecipientEmail,
    @body = @BodyMessage,
   -- @query = @LogQuery ,
    @subject =@SuccessMessage,
    @Importance = @Importance,
    --@attach_query_result_as_file = 1,
    @query_result_no_padding = 0
    
    SET @Currentcnt=@Currentcnt+1
    END

END