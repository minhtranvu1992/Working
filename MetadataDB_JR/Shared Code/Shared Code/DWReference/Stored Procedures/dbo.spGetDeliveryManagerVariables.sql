
-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/08/19
-- Description:	Returns Delivery Manager Variables
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetDeliveryManagerVariables]
AS
BEGIN
SET NOCOUNT ON

SELECT scEnv.ConfiguredValue AS  'Environment',
scSrv.ConfiguredValue AS  'Server',
dbo.udfPackagePathName(scEnv.ConfiguredValue, SUBSTRING(scDel.ConfiguredValue, 0, CHARINDEX('\', scDel.ConfiguredValue, 2)), SUBSTRING(scDel.ConfiguredValue, CHARINDEX('\', scDel.ConfiguredValue, 2) + 1, LEN(scDel.ConfiguredValue) - CHARINDEX('\', scDel.ConfiguredValue, 2))) AS 'DeliveryExecutionLocation',
scMSDB.ConfiguredValue AS 'ConnStr_msdb'
FROM dbo.SSISConfiguration scEnv
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
INNER JOIN dbo.SSISConfiguration scDel ON scDel.ConfigurationFilter = 'DeliveryExecutionLocation'
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
WHERE scEnv.ConfigurationFilter = 'Environment'
END

