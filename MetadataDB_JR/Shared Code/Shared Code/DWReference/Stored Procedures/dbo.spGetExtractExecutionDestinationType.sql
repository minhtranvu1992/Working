
CREATE PROCEDURE [dbo].[spGetExtractExecutionDestinationType]
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
SELECT st.SourceTypeName AS 'DestinationSourceTypeName'
FROM dbo.ExtractControl ec
INNER JOIN dbo.SourceControl scDestination ON ec.DestinationControlID = scDestination.SourceControlID
INNER JOIN dbo.SourceType st ON st.SourceTypeID = scDestination.SourceTypeID
WHERE ec.ExtractControlID = @ExtractControlID
END

