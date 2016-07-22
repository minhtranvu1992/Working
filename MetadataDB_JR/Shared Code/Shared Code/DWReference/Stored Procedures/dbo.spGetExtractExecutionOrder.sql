-- =============================================
-- Author:	oszymczak
-- Create date: 11/10/2010
-- Description:	Get the Execution Order List For the specified Suite 
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractExecutionOrder]
	@SuiteName VARCHAR(50),
	@ExecutionOrderGroup INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT ExecutionOrder, Count(*) AS PackageCount 
	FROM ExtractControl ec (NOLOCK) 
	INNER JOIN dbo.Suite s (NOLOCK) ON ec.SuiteID = s.SuiteID
	WHERE  s.SuiteName = @SuiteName
	AND ec.Status = 'S'
	AND ec.NextRunDateTime <= GETDATE()
	AND ec.ExecutionOrderGroup = @ExecutionOrderGroup
	GROUP BY ExecutionOrder
	ORDER BY ExecutionOrder
END
