-- =============================================
-- Author:		Irwan Iswadi
-- Create date: 1 Jul 2009
-- Description:	To send the Preprocess log summary email notification
-- =============================================
CREATE PROCEDURE [dbo].[sp_SendEmailPreprocessLog] 
	-- Add the parameters for the stored procedure here
	@RecipientEmail varchar(max) = 0, 
	@PreprocessJobID int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

    DECLARE @SuccessMessage AS VARCHAR(MAX)
    DECLARE @LogQuery AS VARCHAR(MAX)
    DECLARE @Importance AS VARCHAR(20)

    SELECT @SuccessMessage = 
				CASE 
					WHEN MIN(SuccessFlag) = 'N' 
					THEN 'PLM NZ Preprocess Failed' 
					ELSE 'PLM NZ PreProcess Success' END,
		   @Importance =
				CASE 
					WHEN MIN(SuccessFlag) = 'N' 
					THEN 'High' 
					ELSE 'Normal' END
    FROM vi_PreprocessLog_Summary
    WHERE PreProcessJobID = @PreprocessJobID

    SET @LogQuery =  'SELECT PreprocessJobID, 
		''The '' + SourceFileName + '' from the '' + CompressedFileName + '' has '' +  CASE WHEN SuccessFlag = 1 THEN ''valid records'' ELSE ''invalid records'' END + '';'' + Message FROM dbo.PreProcessExecutionLog WHERE PreProcessJobID = ' + CAST(@PreprocessJobID as varchar(15)) 



    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'SQL Admin',
    @recipients = @RecipientEmail,
    @query = @LogQuery ,
    @subject = @SuccessMessage,
    @Importance = @Importance,
    @attach_query_result_as_file = 0,
    @query_result_no_padding = 1

END