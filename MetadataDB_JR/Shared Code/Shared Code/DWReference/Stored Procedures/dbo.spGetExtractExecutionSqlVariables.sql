-- =============================================
-- Author:	oszymczak
-- Create date: 03/08/2011
-- Description:	Get Extract Execution Sql Variables
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractExecutionSqlVariables]
	@ExtractControlID INT
AS
BEGIN
	SET NOCOUNT ON;
SELECT
scSource.SourceName,
scDestination.SourceName AS 'DestinationName',
sscSource.ConfiguredValue AS 'ConnStr_Source',
sscDestination.ConfiguredValue AS 'ConnStr_Destination'
FROM dbo.ExtractControl ec 
INNER JOIN dbo.SourceControl scSource ON ec.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SSISConfiguration sscSource ON sscSource.SSISConfigurationID = scSource.SSISConfigurationID
INNER JOIN dbo.SourceControl scDestination ON ec.DestinationControlID = scDestination.SourceControlID
INNER JOIN dbo.SSISConfiguration sscDestination ON sscDestination.SSISConfigurationID = scDestination.SSISConfigurationID

WHERE ec.ExtractControlID = @ExtractControlID
END


