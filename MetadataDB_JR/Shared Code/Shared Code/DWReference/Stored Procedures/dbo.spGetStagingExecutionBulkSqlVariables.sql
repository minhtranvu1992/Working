CREATE PROCEDURE [dbo].[spGetStagingExecutionBulkSqlVariables]
	@StagingControlID INT
AS
BEGIN
	SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Retrieve values
-------------------------------------------------------------------------------

DECLARE @JobID INT
DECLARE @TempJob TABLE
(
   JobID INT  
)

INSERT INTO @TempJob 
EXEC [dbo].[spGetJobID] @Type = 'StagingJobID'

SELECT @JobID = JobID FROM @TempJob

SELECT 
@JobID AS 'StagingJobID',
sconp.[ConfiguredValue] AS 'ConnStr_Source',
scons.[ConfiguredValue] AS 'ConnStr_Staging',
st.SourceTypeName as 'SourceTypeName'
FROM dbo.StagingControl sc 
INNER JOIN dbo.SourceControl scp ON sc.SourceControlID = scp.SourceControlID
INNER JOIN dbo.SSISConfiguration sconp ON sconp.[SSISConfigurationID] = scp.SSISConfigurationID
INNER JOIN dbo.SourceControl scs ON sc.StagingDestControlID = scs.SourceControlID
INNER JOIN dbo.SSISConfiguration scons ON scons.[SSISConfigurationID] = scs.SSISConfigurationID
INNER JOIN dbo.SourceType st ON scp.SourceTypeID = st.SourceTypeID
WHERE sc.StagingControlID = @StagingControlID
END