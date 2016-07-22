

-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/08/19
-- Description:	Returns Summary Manager Variables
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetSummaryManagerVariables]
AS
BEGIN
SET NOCOUNT ON

SELECT scEnv.ConfiguredValue AS  'Environment',
scSrv.ConfiguredValue AS  'Server',
dbo.udfPackagePathName(scEnv.ConfiguredValue, SUBSTRING(scExec.ConfiguredValue, 0, CHARINDEX('\', scExec.ConfiguredValue, 2)), SUBSTRING(scExec.ConfiguredValue, CHARINDEX('\', scExec.ConfiguredValue, 2) + 1, LEN(scExec.ConfiguredValue) - CHARINDEX('\', scExec.ConfiguredValue, 2))) AS 'SummaryExecutionLocation',
scMSDB.ConfiguredValue AS 'ConnStr_msdb'
FROM dbo.SSISConfiguration scEnv
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scExec ON scExec.ConfigurationFilter = 'SummaryExecutionLocation'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
WHERE scEnv.ConfigurationFilter = 'Environment'
END