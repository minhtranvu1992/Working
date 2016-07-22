CREATE PROCEDURE [dbo].[spInsertExtractExecutionLog]
	@ExtractJobID INT,
    @StartTime VARCHAR(50),
	@ManagerGUID UNIQUEIDENTIFIER,
    @SuccessFlag INT,
    @CompletedFlag INT,
    @MessageSource VARCHAR(1000),
    @Message VARCHAR(MAX),
    @RowsExtracted INT,
    @ExtractStartTime VARCHAR(50),
    @ExtractEndTime VARCHAR(50),
    @NextExtractStartTime VARCHAR(50),
    @ExtractPackagePathAndName VARCHAR(250),
    @ExtractControlID INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ExtractPackageName VARCHAR(50)
DECLARE @ExtractPackagePath VARCHAR(200)
DECLARE @SourceControlID INT
DECLARE @SourceControlValue VARCHAR(255)
DECLARE @DestinationControlID INT
DECLARE @DestinationControlValue VARCHAR(255)
DECLARE @SuiteID INT
DECLARE @SuiteName VARCHAR(50)
DECLARE @ExecutionOrder INT

SELECT 	@ExtractPackageName = ec.ExtractPackageName,
@ExtractPackagePath = ec.ExtractPackagePath,
@SourceControlID = ec.SourceControlID,
@SourceControlValue = SourceSSC.ConfiguredValue,
@DestinationControlID = ec.DestinationControlID,
@DestinationControlValue = DestinationSSC.ConfiguredValue,
@SuiteID = ec.SuiteID,
@SuiteName = s.SuiteName,
@ExecutionOrder = ec.ExecutionOrder
FROM dbo.ExtractControl ec
INNER JOIN dbo.Suite s ON ec.SuiteID = s.SuiteID
INNER JOIN dbo.SourceControl SourceSC ON ec.SourceControlID = SourceSC.SourceControlID
INNER JOIN dbo.SSISConfiguration SourceSSC ON SourceSC.SSISConfigurationID = SourceSSC.SSISConfigurationID
INNER JOIN dbo.SourceControl DestinationSC ON ec.DestinationControlID = DestinationSC.SourceControlID
INNER JOIN dbo.SSISConfiguration DestinationSSC ON DestinationSC.SSISConfigurationID = DestinationSSC.SSISConfigurationID
WHERE ec.ExtractControlID = @ExtractControlID

INSERT INTO ExtractExecutionLog
(
	ExtractJobID,
	StartTime,
	EndTime,
	ManagerGUID,
	SuccessFlag,
	CompletedFlag,
	MessageSource,
	Message,
	RowsExtracted,
	ExtractPackagePathAndName,
	ExtractPackageName,
	ExtractPackagePath,
	SourceControlID,
	SourceControlValue,
	DestinationControlID,
	DestinationControlValue,
	SuiteID,
	SuiteName,
	ExecutionOrder,
	ExtractStartTime,
	ExtractEndTime,
	NextExtractStartTime,
	ExtractControlID
)
VALUES
(
	@ExtractJobID,
	@StartTime,
	GETDATE(),
	@ManagerGUID,
	@SuccessFlag,
	@CompletedFlag,
	@MessageSource,
	@Message,
	@RowsExtracted,
	@ExtractPackagePathAndName,
	@ExtractPackageName,
	@ExtractPackagePath,
	@SourceControlID,
	@SourceControlValue,
	@DestinationControlID,
	@DestinationControlValue,
	@SuiteID,
	@SuiteName,
	@ExecutionOrder,
	@ExtractStartTime,
	@ExtractEndTime,
	@NextExtractStartTime,
	@ExtractControlID
)

IF @SuccessFlag = 1 AND @CompletedFlag = 1
BEGIN
	UPDATE ExtractControl
	SET ExtractStartTime = @NextExtractStartTime, LastExtractJobID = @ExtractJobID
	WHERE ExtractControlID = @ExtractControlID
	EXEC spUpdateExtractExecutionStatus @ExtractControlID, 'S'
END
ELSE IF @SuccessFlag = 0 AND @CompletedFlag = 1
BEGIN
	EXEC spUpdateExtractExecutionStatus @ExtractControlID, 'F'
END
END

