


CREATE PROCEDURE [dbo].[spGetJobID] 
	-- Add the parameters for the stored procedure here
	@Type varchar(50)  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @Type = 'DeliveryJobID' OR @Type = 'ExtractJobID' OR @Type = 'SummaryJobID' OR @Type = 'StagingJobID'
	BEGIN
		BEGIN TRAN  
			--Increment the JobID
			DECLARE @ETLParameterValue TABLE
			(
			  JobID NVARCHAR(100)
			);
			
			UPDATE ETLParameters
			SET ETLParameterValue = CAST((CAST(ETLParameterValue AS INT) + 1) AS VARCHAR(50))
			OUTPUT INSERTED.ETLParameterValue
			INTO @ETLParameterValue
			WHERE ETLParameterName = @Type
			
			SELECT CAST(JobID AS INT) AS 'JobID' FROM @ETLParameterValue
		COMMIT TRAN
	END 
END
