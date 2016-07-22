

CREATE PROCEDURE [dbo].[spInsertStagingExecutionLog]
	@StagingJobID INT,
    @StartTime VARCHAR(50),
	@ManagerGUID UNIQUEIDENTIFIER,
    @SuccessFlag INT,
    @CompletedFlag INT,
    @MessageSource VARCHAR(1000),
    @Message VARCHAR(MAX),
    @RowsStaged INT,
	@RowsInserted INT,
	@RowsDeleted INT,
	@RowsUpdated INT,
	@StagingPackagePathAndName VARCHAR(250),
	@ActualFileName VARCHAR(200),
	@ExtractStartTime DATETIME,
	@ExtractEndTime DATETIME,
    @StagingControlID INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @StagingPackageName VARCHAR(50)
DECLARE @StagingPackagePath VARCHAR(200)
DECLARE @SourceControlID INT
DECLARE @SourceControlValue VARCHAR(255)
DECLARE @StagingDestControlID INT
DECLARE @StagingDestControlValue VARCHAR(255)
DECLARE @SuiteID INT
DECLARE @SuiteName VARCHAR(50)
DECLARE @RunAs32Bit VARCHAR(50)


SELECT 	@StagingPackageName = sc.StagingPackageName,
@StagingPackagePath = sc.StagingPackagePath,
@SourceControlID = sc.SourceControlID,
@SourceControlValue = SourceSSC.ConfiguredValue,
@StagingDestControlID = sc.StagingDestControlID,
@StagingDestControlValue = StagingSSC.ConfiguredValue,
@SuiteID = sc.SuiteID,
@SuiteName = s.SuiteName,
@RunAs32Bit = sc.RunAs32Bit
FROM dbo.StagingControl sc
LEFT JOIN dbo.Suite s ON sc.SuiteID = s.SuiteID
INNER JOIN dbo.SourceControl SourceSC ON sc.SourceControlID = SourceSC.SourceControlID
INNER JOIN dbo.SSISConfiguration SourceSSC ON SourceSC.SSISConfigurationID = SourceSSC.SSISConfigurationID
INNER JOIN dbo.SourceControl StagingSC ON sc.StagingDestControlID = StagingSC.SourceControlID
INNER JOIN dbo.SSISConfiguration StagingSSC ON StagingSC.SSISConfigurationID = StagingSSC.SSISConfigurationID
WHERE sc.StagingControlID = @StagingControlID

INSERT INTO StagingExecutionLog
(
	StagingJobID,
	StartTime,
	EndTime,
	ManagerGUID,
	SuccessFlag,
	CompletedFlag,
	MessageSource,
	Message,
	RowsStaged,
	RowsInserted,
	RowsDeleted,
	RowsUpdated,
	StagingControlID,
	StagingPackagePathAndName,
	StagingPackageName,
	StagingPackagePath,
	ActualFileName,
	SourceControlID,
	SourceControlValue,
	StagingDestControlID,
	StagingDestControlValue,
	SuiteID,
	SuiteName,
	RunAs32Bit,
	ExtractStartTime,
	ExtractEndTime	
)
VALUES
(
	@StagingJobID,
	@StartTime,
	GETDATE(),
	@ManagerGUID,
	@SuccessFlag,
	@CompletedFlag,
	@MessageSource,
	@Message,
	@RowsStaged,
	@RowsInserted,
	@RowsDeleted,
	@RowsUpdated,
	@StagingControlID,
	@StagingPackagePathAndName,
	@StagingPackageName,
	@StagingPackagePath,
	@ActualFileName,
	@SourceControlID,
	@SourceControlValue,
	@StagingDestControlID,
	@StagingDestControlValue,
	@SuiteID,
	@SuiteName,
	@RunAs32Bit,
	@ExtractStartTime,
	@ExtractEndTime
)

IF @ActualFileName IS NOT NULL OR LEN(@ActualFileName)> 0
BEGIN
	UPDATE [dbo].[StagingControl] SET [LastProcessedTime] = GETDATE()  WHERE [StagingControlID] = @StagingControlID
END

IF @SuccessFlag = 1 AND @CompletedFlag = 1
BEGIN
	UPDATE StagingControl
	SET LastExecutionTime = @ExtractEndTime, LastStagingJobID = @StagingJobID
	WHERE StagingControlID = @StagingControlID
	EXEC spUpdateStagingExecutionStatus @StagingControlID, 'S'
END
ELSE IF @SuccessFlag = 0 AND @CompletedFlag = 1
BEGIN
	EXEC spUpdateStagingExecutionStatus @StagingControlID, 'F'
END

END