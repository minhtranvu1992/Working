
CREATE PROCEDURE [dbo].[spGetExtractExecutionSourceDestType]
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
SELECT stSource.SourceTypeName AS 'SourceTypeName',
stDest.SourceTypeName AS 'DestinationSourceTypeName'
FROM dbo.ExtractControl ec
INNER JOIN dbo.SourceControl scSource ON ec.SourceControlID = scSource.SourceControlID
INNER JOIN dbo.SourceType stSource ON stSource.SourceTypeID = scSource.SourceTypeID
INNER JOIN dbo.SourceControl scDestination ON ec.DestinationControlID = scDestination.SourceControlID
INNER JOIN dbo.SourceType stDest ON stDest.SourceTypeID = scDestination.SourceTypeID
WHERE ec.ExtractControlID = @ExtractControlID
END
