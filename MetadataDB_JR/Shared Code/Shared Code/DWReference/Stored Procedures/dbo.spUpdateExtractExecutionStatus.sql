


CREATE PROCEDURE [dbo].[spUpdateExtractExecutionStatus]
	@ExtractControlID INT,
	@Status VARCHAR(1)
	
AS
BEGIN
DECLARE @FailedCount INT
DECLARE @ScheduleID INT
DECLARE @GetDate DATETIME
DECLARE @NextRunDateTime DATETIME


	IF EXISTS (SELECT 1 FROM ExtractControl WHERE ExtractControlID = @ExtractControlID )
	BEGIN

		SELECT @FailedCount = ISNULL(FailedCount, 0) 
		FROM ExtractControl 
		WHERE ExtractControlID = @ExtractControlID 



		IF @Status = 'F'
		AND @FailedCount <= 1
		BEGIN
		UPDATE ExtractControl
			SET Status = 'S',
			FailedCount = @FailedCount + 1,
			FailedCountEmailSent = NULL,
			StatusChangeDateTime = GETDATE()	
			WHERE ExtractControlID = @ExtractControlID 
		END
		ELSE IF @Status = 'S'
		BEGIN
			SELECT @ScheduleID = ScheduleID FROM dbo.ExtractControl WHERE ExtractControlID = @ExtractControlID
			SET @GetDate = GETDATE()

			EXEC [dbo].[spGetNextTime] @GetDate, @ScheduleID, @NextRunDateTime OUTPUT

			UPDATE ExtractControl
			SET Status = @Status,
			FailedCount = 0,
			StatusChangeDateTime = GETDATE(),
			FailedCountEmailSent = NULL,
			MaxExpectedExecutionEmailSent = NULL,
			NextRunDateTime = @NextRunDateTime
			WHERE ExtractControlID = @ExtractControlID 
		END
		ELSE
		BEGIN
			UPDATE ExtractControl
			SET Status = @Status,
			StatusChangeDateTime = GETDATE(),
			FailedCountEmailSent = NULL,
			MaxExpectedExecutionEmailSent = NULL
			WHERE ExtractControlID = @ExtractControlID 
		END
	END
END



