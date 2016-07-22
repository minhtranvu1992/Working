
-------------------------------------------------------------------------------
-- Author:	oszymczak
-- Create date: 2013/11/13
-- Description:	log summary execution
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[spInsertSummaryExecutionLog]
	@SummaryControlID INT
	,@SummaryJobID INT
    ,@DeliveryJobID INT
    ,@StartTime DATETIME
    ,@ManagerGUID UNIQUEIDENTIFIER
    ,@SuccessFlag INT
    ,@CompletedFlag INT
    ,@MessageSource VARCHAR(1000)
    ,@Message VARCHAR(1000)
	,@RowsSummarized INT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @SummaryPackageName VARCHAR(100)
DECLARE @SummaryTableName VARCHAR(100)
DECLARE @ExecutionOrder INT
DECLARE @Type VARCHAR(100)
DECLARE @ScheduleType VARCHAR(50)
DECLARE @SourceControlID INT
DECLARE @SourceControlValue VARCHAR(255)

SELECT @SummaryPackageName = sc.SummaryPackageName, @SummaryTableName = sc.SummaryTableName,
@ExecutionOrder = sc.ExecutionOrder, @Type = sc.[Type], @ScheduleType = sc.[ScheduleType], @SourceControlID = sc.SourceControlID,
@SourceControlValue = SourceSSC.ConfiguredValue
FROM [dbo].[SummaryControl] sc
INNER JOIN dbo.SourceControl SourceSC ON sc.SourceControlID = SourceSC.SourceControlID
INNER JOIN dbo.SSISConfiguration SourceSSC ON SourceSC.SSISConfigurationID = SourceSSC.SSISConfigurationID
WHERE SummaryControlID = @SummaryControlID

INSERT INTO [dbo].[SummaryExecutionLog]
           ([SummaryControlID]
		   ,[SummaryJobID]
           ,[DeliveryJobID]
           ,[SummaryPackageName]
		   ,SummaryTableName
           ,[StartTime]
           ,[EndTime]
		   ,[ManagerGUID]
           ,[SuccessFlag]
           ,[CompletedFlag]
           ,[MessageSource]
           ,[Message]
           ,[ScheduleType]
           ,[ExecutionOrder]
           ,[SourceControlID]
           ,[SourceControlValue]
		   ,[Type]
		   ,RowsSummarized)
     VALUES
           (@SummaryControlID
		   ,@SummaryJobID
           ,@DeliveryJobID
           ,@SummaryPackageName
		   ,@SummaryTableName
           ,@StartTime
           ,GETDATE()
		   ,@ManagerGUID
           ,@SuccessFlag
           ,@CompletedFlag
           ,@MessageSource
           ,@Message
           ,@ScheduleType
           ,@ExecutionOrder
           ,@SourceControlID
           ,@SourceControlValue
		   ,@Type
		   ,@RowsSummarized)

IF @SuccessFlag = 1 AND @CompletedFlag = 1
BEGIN
	UPDATE [SummaryControl]
	SET LastDeliveryJobID = @DeliveryJobID
	,LastSummaryJobID = @SummaryJobID
	,LastExecutionTime = GETDATE()
	WHERE SummaryControlID = @SummaryControlID
END

END