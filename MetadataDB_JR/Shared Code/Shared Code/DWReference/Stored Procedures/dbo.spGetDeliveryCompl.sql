


CREATE PROCEDURE [dbo].[spGetDeliveryCompl]
	@ExecutionOrder INT,
	@DeliveryJobID INT
AS
BEGIN
SET NOCOUNT ON;
	SELECT Count(DISTINCT DeliveryPackageName) AS ExecutedPackageCount 
	FROM DeliveryExecutionLog (NOLOCK) dc 
	WHERE dc.CompletedFlag = 1
	AND dc.ExecutionOrder = @ExecutionOrder
	AND dc.DeliveryJobID = @DeliveryJobID
END

