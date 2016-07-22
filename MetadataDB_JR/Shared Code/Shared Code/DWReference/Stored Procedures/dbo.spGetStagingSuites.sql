

-- =============================================
-- Author:	oszymczak
-- Create date: 25/03/2014
-- Description:	Get StagingControl Suites
-- =============================================
CREATE PROCEDURE [dbo].[spGetStagingSuites]
AS
BEGIN
	SET NOCOUNT ON;

	SET NOCOUNT ON;
	DECLARE @ErrorMessage NVARCHAR(1000)

	IF EXISTS(	SELECT DISTINCT 1
	FROM dbo.Suite s (NOLOCK)
	INNER JOIN dbo.StagingControl sc (NOLOCK) ON s.SuiteID = sc.SuiteID
	WHERE sc.Status IS NULL OR sc.Status IS NULL
	)
	BEGIN

		SET @ErrorMessage = 'GetStagingSuites|Suite has not been correctly setup it is missing.'
		RAISERROR(@ErrorMessage, 16, 1);
	END


	SELECT DISTINCT s.SuiteName AS 'Suite'
	FROM dbo.Suite s (NOLOCK)
	INNER JOIN dbo.StagingControl sc (NOLOCK) ON s.SuiteID = sc.SuiteID
	LEFT JOIN dbo.SourceControl SourceSC (NOLOCK) ON sc.SourceControlID = SourceSC.SourceControlID
	LEFT JOIN dbo.SSISConfiguration SourceSSC (NOLOCK) ON SourceSC.SSISConfigurationID = SourceSSC.SSISConfigurationID
	WHERE s.Status = 'S'
	AND sc.Status = 'S'
	AND ((ProcessType = 'BULKFILE') OR (ProcessType = 'BULKSQL' AND NextRunDateTime <= GETDATE()))
	ORDER BY s.SuiteName
END