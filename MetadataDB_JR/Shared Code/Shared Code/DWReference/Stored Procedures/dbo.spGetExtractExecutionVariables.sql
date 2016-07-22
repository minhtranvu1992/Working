
-- =============================================
-- Author:	oszymczak
-- Create date: 03/08/2011
-- Description:	Get Extract Execution
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractExecutionVariables]
AS
BEGIN
	SET NOCOUNT ON

SELECT
scMSDB.ConfiguredValue AS 'ConnStr_msdb',
scSrv.ConfiguredValue AS  'Server'
FROM dbo.SSISConfiguration scMSDB 
INNER JOIN dbo.SSISConfiguration scSrv ON scSrv.ConfigurationFilter = 'Server'
WHERE scMSDB.ConfigurationFilter = 'ConnStr_msdb'
END

