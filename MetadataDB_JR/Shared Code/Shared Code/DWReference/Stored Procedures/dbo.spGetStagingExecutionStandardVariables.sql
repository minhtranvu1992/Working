
CREATE PROCEDURE [dbo].[spGetStagingExecutionStandardVariables]
	@StagingControlID INT
AS
BEGIN
SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Set Status
-------------------------------------------------------------------------------
EXEC [spUpdateStagingExecutionStatus] @StagingControlID, 'P'
-------------------------------------------------------------------------------
-- Retrieve values
-------------------------------------------------------------------------------
SELECT
COALESCE(sc.StagingPackageName,'') AS 'StagingPackageName',
COALESCE(s.SuiteName, '') AS 'Suite',
CONVERT(CHAR(23), COALESCE(LastExecutionTime,'1900-01-01'), 121) AS 'ExtractStartTime',
COALESCE(sc.StagingPackagePath,'') AS 'StagingPackagePath',
COALESCE(sc.StagingTable,'') AS 'StagingTable',
COALESCE(dbo.udfPackagePathName(scEnv.ConfiguredValue, sc.StagingPackagePath, sc.StagingPackageName), '') AS 'StagingPathAndName',
COALESCE(scEnv.ConfiguredValue,'') AS 'Environment',
COALESCE(scSrv.ConfiguredValue,'') AS 'Server',
COALESCE(scMSDB.ConfiguredValue,'') AS 'ConnStr_msdb',
COALESCE(sc.ProcessType,'') AS 'ProcessType',
COALESCE(sc.SourceQuery,'') AS 'SourceQuery',
COALESCE(sc.SourceQueryMapping,'') AS 'SourceQueryMapping',
COALESCE(sc.MergeQuery,'') AS 'MergeQuery',
COALESCE(scBup.ConfiguredValue, '') AS 'BulkUploadLoadSize',
ISNULL(sc.TruncateStagingTable,0) AS 'TruncateStagingTable'
FROM dbo.StagingControl sc 
INNER JOIN dbo.Suite s ON sc.SuiteID = s.SuiteID
INNER JOIN dbo.SSISConfiguration scEnv ON scEnv.ConfigurationFilter = 'Environment'
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
INNER JOIN dbo.SSISConfiguration scBup ON scBup.ConfigurationFilter = 'BulkUploadLoadSize'
WHERE sc.StagingControlID = @StagingControlID
END