-- =============================================
-- Author:	oszymczak
-- Create date: 06/05/2014
-- Description:	Get Staging Packages based on Suite 
-- =============================================
CREATE PROCEDURE [dbo].[spGetStagingPackagesSql]
	@SuiteName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT sc.StagingControlID
	FROM dbo.StagingControl sc (NOLOCK)
	INNER JOIN dbo.Suite s (NOLOCK) ON sc.SuiteID = s.SuiteID
	WHERE	
	s.SuiteName = @SuiteName
	AND sc.NextRunDateTime <= GETDATE()
	AND sc.Status = 'S'
	AND sc.ProcessType = 'BULKSQL'
END