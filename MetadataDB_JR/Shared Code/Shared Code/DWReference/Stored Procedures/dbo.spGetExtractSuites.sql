-- =============================================
-- Author:	oszymczak
-- Create date: 03/08/2011
-- Description:	Get Extract Suites
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractSuites]
	@ExecutionOrderGroup INT
AS
BEGIN
	SET NOCOUNT ON;
-------------------------------------------------------------------------------
-- Ensure that the same suite cannot run concurrently
-------------------------------------------------------------------------------	
	DECLARE @StatusChangeDateTime DATETIME = GETDATE()
	
	UPDATE dbo.Suite SET Status = 'P', StatusChangeDateTime = @StatusChangeDateTime
	FROM  dbo.Suite s (NOLOCK)
	INNER JOIN dbo.ExtractControl ec (NOLOCK) ON s.SuiteID = ec.SuiteID
	WHERE ec.NextRunDateTime <= GETDATE()
	AND ec.Status = 'S'
	AND s.Status = 'S'
	AND ec.ExecutionOrderGroup = @ExecutionOrderGroup
	
-------------------------------------------------------------------------------	
-- Return result
-------------------------------------------------------------------------------		
	SELECT DISTINCT s.SuiteName AS 'Suite'
	FROM dbo.Suite s (NOLOCK)
	INNER JOIN dbo.ExtractControl ec (NOLOCK) ON s.SuiteID = ec.SuiteID	
	WHERE ec.NextRunDateTime <= GETDATE()
	AND ec.Status = 'S'
	AND s.Status = 'P'
	AND s.StatusChangeDateTime = @StatusChangeDateTime
	AND ec.ExecutionOrderGroup = @ExecutionOrderGroup
	GROUP BY s.SuiteName
	ORDER BY s.SuiteName
END
