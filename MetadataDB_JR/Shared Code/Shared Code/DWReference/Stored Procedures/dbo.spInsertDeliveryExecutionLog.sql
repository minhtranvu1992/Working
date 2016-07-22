
-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/08/19
-- Description:	Return packages that will be executed based on ScheduleType 
--              and ExecutionOrder
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spInsertDeliveryExecutionLog]
	@DeliveryControlID INT
	,@DeliveryJobID INT
    ,@ExtractJobID INT
    ,@StartTime DATETIME
    ,@ManagerGUID UNIQUEIDENTIFIER
    ,@SuccessFlag INT
    ,@CompletedFlag INT
    ,@MessageSource VARCHAR(1000)
    ,@Message VARCHAR(1000)
    ,@RowsDelivered INT
    ,@RowsErrored INT  
    ,@LastExecutionTime DATETIME
    ,@NextLastExecutionTime DATETIME
    ,@DeliveryPackagePathAndName VARCHAR(250)
    
AS
BEGIN
SET NOCOUNT ON;

DECLARE @DeliveryPackageName VARCHAR(100)
DECLARE @DeliveryPackagePath VARCHAR(100)
DECLARE @ExecutionOrder INT
DECLARE @ScheduleType VARCHAR(100)

SELECT @DeliveryPackageName = DeliveryPackageName, @DeliveryPackagePath = DeliveryPackagePath,
@ExecutionOrder = ExecutionOrder, @ScheduleType = ScheduleType
FROM dbo.DeliveryControl WHERE DeliveryControlID = @DeliveryControlID

INSERT INTO DeliveryExecutionLog
           (DeliveryControlID
		   ,DeliveryJobID
		   ,ExtractJobID
           ,StartTime
           ,EndTime
		   ,ManagerGUID
           ,SuccessFlag
		   ,CompletedFlag
           ,MessageSource
           ,Message
           ,RowsDelivered
		   ,RowsErrored
           ,LastExecutionTime
           ,NextLastExecutionTime
		   ,DeliveryPackagePathAndName
		   ,DeliveryPackageName
		   ,DeliveryPackagePath
		   ,ExecutionOrder
		   ,ScheduleType
          )
     VALUES
           (@DeliveryControlID
		   ,@DeliveryJobID
		   ,@ExtractJobID
           ,@StartTime
           ,GETDATE()
		   ,@ManagerGUID
           ,@SuccessFlag
		   ,@CompletedFlag
           ,@MessageSource
           ,@Message
           ,@RowsDelivered
		   ,@RowsErrored
           ,@LastExecutionTime
           ,@NextLastExecutionTime
		   ,@DeliveryPackagePathAndName
		   ,@DeliveryPackageName
		   ,@DeliveryPackagePath
		   ,@ExecutionOrder
		   ,@ScheduleType
           )
END
