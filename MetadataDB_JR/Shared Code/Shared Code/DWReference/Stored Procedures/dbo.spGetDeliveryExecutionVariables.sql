-- =============================================
-- Author:	oszymczak
-- Create date: 03/08/2011
-- Description:	Get Delivery Execution Variables
-- =============================================
CREATE PROCEDURE [dbo].[spGetDeliveryExecutionVariables]
	@DeliveryControlID INT
AS
BEGIN
SET NOCOUNT ON;

SELECT 
CONVERT(CHAR(23), GETDATE(), 121) AS StartTime,
DeliveryPackagePath,
DeliveryPackageName,
DeliveryTable,
ExtractTable,
ErrorTable,
ExecutionOrder,
ProcessType,
CONVERT(CHAR(23), LastExecutionTime, 121) AS LastExecutionTime,
LastExtractJobID,
scMSDB.ConfiguredValue AS ConnStr_msdb,
scExtract.ConfiguredValue AS  ConnStr_Extract,
scDW.ConfiguredValue AS  ConnStr_DW,
scEnv.ConfiguredValue AS  Environment,
dbo.udfPackagePathName(scEnv.ConfiguredValue, dc.DeliveryPackagePath, dc.DeliveryPackageName) AS 'DerivedPathAndName',
dc.InsertOnly
FROM 
DeliveryControl  dc
INNER JOIN dbo.SSISConfiguration scMSDB ON scMSDB.ConfigurationFilter = 'ConnStr_msdb'
INNER JOIN dbo.SSISConfiguration scExtract ON scExtract.ConfigurationFilter = 'ConnStr_DWExtract_DB'
INNER JOIN dbo.SSISConfiguration scDW ON scDW.ConfigurationFilter = 'ConnStr_DWData_DB'
INNER JOIN dbo.SSISConfiguration scEnv ON scEnv.ConfigurationFilter = 'Environment'
WHERE
DeliveryControlID = @DeliveryControlID
END

