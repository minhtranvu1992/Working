


-- =============================================
-- Author:	oszymczak
-- Create date: 03/08/2011
-- Description:	Get the Extract Packages based on Exectuion Order and Suite 
-- =============================================
CREATE PROCEDURE [dbo].[spGetExtractPackages]
	@SuiteName VARCHAR(50),
	@ExecutionOrder INT,
	@ExecutionOrderGroup INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT sc.AccessWindowStartMins, ec.ExtractControlID, ec.ExtractPackageName, COALESCE(ec.RunAs32Bit, 'False') AS RunAs32bit
	FROM 
	dbo.SourceControl sc (NOLOCK)
	INNER JOIN dbo.ExtractControl ec (NOLOCK)  ON sc.SourceControlID = ec.SourceControlID
	INNER JOIN dbo.Suite s (NOLOCK) ON ec.SuiteID = s.SuiteID
	WHERE	
	s.SuiteName = @SuiteName
	AND ec.ExecutionOrder = @ExecutionOrder
	AND ec.NextRunDateTime <= GETDATE()
	AND ec.Status = 'S'
	AND ec.ExecutionOrderGroup = @ExecutionOrderGroup
	ORDER BY 
	sc.AccessWindowStartMins	
END
