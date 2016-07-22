
CREATE PROCEDURE [dbo].[spGetExtractCompl]
	@SuiteName VARCHAR(50),
	@ExecutuionOrder INT,
	@ExtractJobID INT
AS
BEGIN
SET NOCOUNT ON;

SELECT Count(DISTINCT ExtractControlID) AS ExecutedPackageCount 
FROM ExtractExecutionLog (NOLOCK) ec 
INNER JOIN dbo.Suite s ON ec.SuiteID = s.SuiteID
WHERE ec.CompletedFlag = 1
AND s.SuiteName = @SuiteName
AND ec.ExecutionOrder = @ExecutuionOrder
AND ec.ExtractJobID = @ExtractJobID
END


