

CREATE PROCEDURE [dbo].[spGetExtractExecutionDestFileVariables]
		@ExtractControlID INT
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT
sscDestination.ConfiguredValue AS 'FileDestination',
ec.ExtractTable AS 'FileName'
FROM dbo.ExtractControl ec 
INNER JOIN dbo.Suite s ON ec.SuiteID = s.SuiteID
INNER JOIN dbo.SourceControl scSource ON ec.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SSISConfiguration sscSource ON sscSource.SSISConfigurationID = scSource.SSISConfigurationID
INNER JOIN dbo.SourceControl scDestination ON ec.DestinationControlID = scDestination.SourceControlID
INNER JOIN dbo.SSISConfiguration sscDestination ON sscDestination.SSISConfigurationID = scDestination.SSISConfigurationID
WHERE ec.ExtractControlID = @ExtractControlID
END

