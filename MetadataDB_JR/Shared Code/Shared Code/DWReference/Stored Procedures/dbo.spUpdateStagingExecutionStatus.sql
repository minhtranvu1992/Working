

CREATE PROCEDURE [dbo].[spUpdateStagingExecutionStatus]
	@StagingControlID INT,
	@Status VARCHAR(1)
	
AS
BEGIN
DECLARE @FailedCount INT
DECLARE @ScheduleID INT
DECLARE @GetDate DATETIME
DECLARE @NextRunDateTime DATETIME


	IF EXISTS (SELECT 1 FROM StagingControl WHERE StagingControlID = @StagingControlID )
	BEGIN

		SELECT @FailedCount = ISNULL(FailedCount, 0) 
		FROM StagingControl 
		WHERE StagingControlID = @StagingControlID 



		IF @Status = 'F'
		AND @FailedCount <= 1
		BEGIN
		UPDATE StagingControl
			SET Status = 'S',
			FailedCount = @FailedCount + 1,
			FailedCountEmailSent = NULL,
			StatusChangeDateTime = GETDATE()	
			WHERE StagingControlID = @StagingControlID 
		END
		ELSE IF @Status = 'S'
		BEGIN
			SELECT @ScheduleID = ScheduleID FROM dbo.StagingControl WHERE StagingControlID = @StagingControlID
			SET @GetDate = GETDATE()

			IF(@ScheduleID IS NOT NULL)
			BEGIN
				EXEC [dbo].[spGetNextTime] @GetDate, @ScheduleID, @NextRunDateTime OUTPUT
			END

			UPDATE StagingControl
			SET Status = @Status,
			FailedCount = 0,
			StatusChangeDateTime = GETDATE(),
			FailedCountEmailSent = NULL,
			MaxExpectedExecutionEmailSent = NULL,
			NextRunDateTime = @NextRunDateTime
			WHERE StagingControlID = @StagingControlID 
		END
		ELSE
		BEGIN
			UPDATE StagingControl
			SET Status = @Status,
			StatusChangeDateTime = GETDATE(),
			FailedCountEmailSent = NULL,
			MaxExpectedExecutionEmailSent = NULL
			WHERE StagingControlID = @StagingControlID 
		END
	END
END