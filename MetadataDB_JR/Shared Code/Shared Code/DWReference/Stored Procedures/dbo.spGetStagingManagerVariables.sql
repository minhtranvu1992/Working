

-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2014/03/28
-- Description:	Returns Staging Manager Variables
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetStagingManagerVariables]
AS
BEGIN
SET NOCOUNT ON

SELECT scSrv.ConfiguredValue AS  'Server',
dbo.udfPackagePathName(scEnv.ConfiguredValue, SUBSTRING(scDel.ConfiguredValue, 0, CHARINDEX('\', scDel.ConfiguredValue, 2)), SUBSTRING(scDel.ConfiguredValue, CHARINDEX('\', scDel.ConfiguredValue, 2) + 1, LEN(scDel.ConfiguredValue) - CHARINDEX('\', scDel.ConfiguredValue, 2))) AS 'StagingExecutionLocation',
scMSDB.ConfiguredValue AS 'ConnStr_msdb',
scFS.ConfiguredValue AS 'FileNameSeparator'
FROM dbo.SSISConfiguration scEnv
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scDel ON scDel.ConfigurationFilter = 'StagingExecutionLocation'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
INNER JOIN dbo.SSISConfiguration scFS ON scFS.ConfigurationFilter = 'FileNameSeparator'
WHERE scEnv.ConfigurationFilter = 'Environment'
END