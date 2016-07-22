CREATE PROCEDURE [dbo].[spGetSummaryCompl]
	@ExecutuionOrder INT,
	@SummaryJobID INT
AS
BEGIN
SET NOCOUNT ON;
	SELECT Count(DISTINCT SummaryPackageName) AS ExecutedPackageCount 
	FROM SummaryExecutionLog (NOLOCK) sc 
	WHERE sc.CompletedFlag = 1
	AND sc.ExecutionOrder = @ExecutuionOrder
	AND sc.SummaryJobID = @SummaryJobID
END