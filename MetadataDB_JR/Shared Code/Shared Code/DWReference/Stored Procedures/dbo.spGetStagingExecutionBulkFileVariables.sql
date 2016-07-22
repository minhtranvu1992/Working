CREATE PROCEDURE [dbo].[spGetStagingExecutionBulkFileVariables]
	@StagingControlID INT
AS
BEGIN
	SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Retrieve values
-------------------------------------------------------------------------------
SELECT 
sconp.[ConfiguredValue] AS 'FolderBaseLocation',
scons.[ConfiguredValue] AS 'ConnStr_Staging',
sc.HasFooter,
sc.HasHeader,
sc.DelimiterChar,
COALESCE(scFNS.ConfiguredValue, '') AS 'FileNameSeparator',
COALESCE(scFts.ConfiguredValue, '') AS 'FileTimeStampFormat'
FROM dbo.StagingControl sc 
INNER JOIN dbo.SourceControl scp ON sc.SourceControlID = scp.SourceControlID
INNER JOIN dbo.SSISConfiguration sconp ON sconp.[SSISConfigurationID] = scp.SSISConfigurationID
INNER JOIN dbo.SourceControl scs ON sc.StagingDestControlID = scs.SourceControlID
INNER JOIN dbo.SSISConfiguration scons ON scons.[SSISConfigurationID] = scs.SSISConfigurationID
INNER JOIN dbo.SSISConfiguration scFNS ON scFNS.ConfigurationFilter = 'FileNameSeparator'
INNER JOIN dbo.SSISConfiguration scFts ON scFts.ConfigurationFilter = 'FileTimeStampFormat'
WHERE sc.ProcessType = 'BULKFILE'
AND sc.StagingControlID = @StagingControlID
END