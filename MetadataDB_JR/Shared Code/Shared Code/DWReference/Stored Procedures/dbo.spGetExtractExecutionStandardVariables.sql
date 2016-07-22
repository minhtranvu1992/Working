
CREATE PROCEDURE [dbo].[spGetExtractExecutionStandardVariables]
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
COALESCE(ec.ExtractPackageName,'') AS 'ExtractPackageName',
COALESCE(sComp.SuiteName, s.SuiteName,'') AS 'Suite',
CONVERT(CHAR(23), GETDATE(), 121) AS StartTime,
ec.ExecutionOrder,
scSource.AccessWindowEndMins,
COALESCE(ec.ExtractPackagePath,'') AS 'ExtractPackagePath',
COALESCE(ec.ExtractTable,'') AS 'ExtractTable',
COALESCE(dbo.udfPackagePathName(scEnv.ConfiguredValue, ec.ExtractPackagePath, ec.ExtractPackageName), '') AS 'ExtractPathAndName',
COALESCE(scEnv.ConfiguredValue,'') AS 'Environment',
COALESCE(scSrv.ConfiguredValue,'') AS 'Server',
COALESCE(scMSDB.ConfiguredValue,'') AS 'ConnStr_msdb',
CONVERT(CHAR(23), ec.ExtractStartTime, 121) AS ExtractStartTime,
COALESCE(ec.ConnectionCheckQuery, '') AS ConnectionCheckQuery,
CASE 
	WHEN ec.CheckConnection = 'False' THEN 0 
	ELSE ec.ConnectionCheckResult
END AS ConnectionCheckResult,
COALESCE(ec.DataCurrencyCheckQuery, '') AS DataCurrencyCheckQuery,
CASE 
	WHEN ec.CheckDataCurrency = 'False' THEN 0 
	ELSE ec.DataCurrencyCheckResult
END AS DataCurrencyCheckResult,
COALESCE(ec.CheckConnection, 'False') AS CheckConnection,
COALESCE(ec.CheckDataCurrency, 'False') AS CheckDataCurrency,
ec.CheckExtractRowCount,
COALESCE(ec.ProcessType,'') AS 'ProcessType',
COALESCE(ec.SourceQuery,'') AS 'SourceQuery',
COALESCE(ec.SourceQueryMapping,'') AS 'SourceQueryMapping',
ec.TruncateExtractTable,
COALESCE(scBup.ConfiguredValue, '') AS 'BulkUploadLoadSize'
FROM dbo.ExtractControl ec 
INNER JOIN dbo.Suite s ON ec.SuiteID = s.SuiteID
INNER JOIN dbo.SourceControl scSource ON ec.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SSISConfiguration scEnv ON scEnv.ConfigurationFilter = 'Environment'
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
INNER JOIN dbo.SSISConfiguration scBup ON scBup.ConfigurationFilter = 'BulkUploadLoadSize'
LEFT JOIN dbo.Suite sComp ON ec.CompanySuiteID = sComp.SuiteID
WHERE ec.ExtractControlID = @ExtractControlID
END




