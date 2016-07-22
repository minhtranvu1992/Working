

CREATE PROCEDURE [dbo].[spGetExtractExecutionSourceSqlVariables]
	@ExtractControlID INT
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT
sscSource.ConfiguredValue AS 'ConnStr_Source'
FROM dbo.ExtractControl ec 
INNER JOIN dbo.Suite s ON ec.SuiteID = s.SuiteID
INNER JOIN dbo.SourceControl scSource ON ec.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SSISConfiguration sscSource ON sscSource.SSISConfigurationID = scSource.SSISConfigurationID
WHERE ec.ExtractControlID = @ExtractControlID
END

