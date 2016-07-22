


-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2014/03/28
-- Description:	Folder Location for a suite
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetStagingManagerFolderLocation]
@SuiteName NVARCHAR(50) 
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT sspc.ConfiguredValue AS 'BaseFolder', ssEnv.ConfiguredValue AS 'Environment', s.SuiteName,  'Unprocessed' AS 'Folder' FROM dbo.StagingControl sc
INNER JOIN dbo.SourceControl spc ON spc.SourceControlID = sc.SourceControlID
INNER JOIN dbo.SSISConfiguration sspc ON sspc.SSISConfigurationID = spc.SSISConfigurationID
INNER JOIN dbo.SSISConfiguration ssEnv ON ssEnv.ConfigurationFilter = 'Environment'
INNER JOIN dbo.Suite s ON sc.SuiteID = s.SuiteID
WHERE s.Status = 'S'
AND sc.Status = 'S'
AND sc.ProcessType = 'BULKFILE'
AND s.SuiteName = @SuiteName
END