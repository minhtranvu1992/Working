-- =============================================
-- Author:		Irwan Iswadi
-- Create date: 15 May 2009
-- Description:	To get the Pre process job id
-- =============================================
CREATE PROCEDURE [dbo].[GetPreProcessJobID] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE ETLParameters
	SET ETLParameterValue = CAST((CAST(ETLParameterValue AS INT) + 1) AS VARCHAR(50))
	WHERE ETLParameterName = 'PreProcessJobID'


		-- Insert statements for procedure here
	SELECT CAST(ETLParameterValue AS INT) AS PreProcessJobID 
	FROM ETLParameters WHERE ETLParameterName = 'PreProcessJobID'	

    -- Insert statements for procedure here

END
