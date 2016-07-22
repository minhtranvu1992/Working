
CREATE PROCEDURE [dbo].[spGetExtractExecutionSqlFileVariables]
	@ExtractControlID INT
AS
BEGIN
	SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Set Status
-------------------------------------------------------------------------------
EXEC spUpdateExtractExecutionStatus @ExtractControlID, 'P'
-------------------------------------------------------------------------------
-- Retrieve values
-------------------------------------------------------------------------------
SELECT
ec.ExtractControlID,
CONVERT(CHAR(23), GETDATE(), 121) AS StartTime,
ec.ExecutionOrder,
scSource.AccessWindowEndMins,
ec.ExtractPackagePath,
ec.ExtractTable,
CONVERT(CHAR(23), ec.ExtractStartTime, 121) AS ExtractStartTime,
COALESCE(ec.RunAs32Bit, 'False') AS RunAs32bit,
sscSource.ConfiguredValue AS 'ConnStr_Source',
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



