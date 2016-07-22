-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/08/19
-- Description:	Return packages that will be executed based on ScheduleType 
--              and ExecutionOrder
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetSummaryManagerPackages]
	@ScheduleType VARCHAR(100),
	@ExecutionOrder INT
AS
BEGIN
SET NOCOUNT ON;

SELECT SummaryControlID
FROM SummaryControl
WHERE ScheduleType = @ScheduleType
AND ExecutionOrder = @ExecutionOrder
AND ISNULL(LastDeliveryJobID, -1) <> ISNULL(CurrentDeliveryJobID, -1)
END