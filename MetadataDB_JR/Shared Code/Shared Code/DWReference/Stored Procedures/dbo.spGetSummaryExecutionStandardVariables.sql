CREATE PROCEDURE [dbo].[spGetSummaryExecutionStandardVariables]
	@SummaryControlID INT
AS
BEGIN
	SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Retrieve values
-------------------------------------------------------------------------------
SELECT
sc.[SummaryPackageName],
sc.[SummaryPackagePath],
sc.[SummaryTableName],
sc.[SourceQuery],
sc.[Type],
sc.[ScheduleType],
dbo.udfPackagePathName(scEnv.ConfiguredValue, sc.SummaryPackagePath, sc.SummaryPackageName) AS 'SummaryPathAndName',
sscSource.ConfiguredValue AS 'ConnStr_Source',
scMSDB.ConfiguredValue AS 'ConnStr_msdb',
CONVERT(CHAR(23), sc.LastExecutionTime, 121) AS LastExecutionTime
FROM dbo.SummaryControl sc 
INNER JOIN dbo.SourceControl scSource ON sc.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SSISConfiguration sscSource ON sscSource.SSISConfigurationID = scSource.SSISConfigurationID
INNER JOIN dbo.SSISConfiguration scEnv ON scEnv.ConfigurationFilter = 'Environment'
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
WHERE sc.SummaryControlID = @SummaryControlID
END