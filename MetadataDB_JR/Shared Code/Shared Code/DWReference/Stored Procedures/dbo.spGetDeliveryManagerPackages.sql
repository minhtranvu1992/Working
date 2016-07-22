-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/08/19
-- Description:	Return packages that will be executed based on ScheduleType 
--              and ExecutionOrder
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spGetDeliveryManagerPackages]
	@ScheduleType VARCHAR(100),
	@ExecutionOrder INT
AS
BEGIN
SET NOCOUNT ON;

SELECT DeliveryControlID
FROM DeliveryControl
WHERE ScheduleType = @ScheduleType
AND ExecutionOrder = @ExecutionOrder
AND ISNULL(LastExtractJobID, -1) <> ISNULL(CurrentExtractJobID, -1)
END
