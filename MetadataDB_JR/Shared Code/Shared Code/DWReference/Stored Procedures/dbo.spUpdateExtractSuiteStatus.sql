
CREATE PROCEDURE [dbo].[spUpdateExtractSuiteStatus]
	@SuiteName VARCHAR(50),
	@Status CHAR(1)	
AS
BEGIN 
IF @Status = 'F'
	BEGIN
		UPDATE Suite SET Status = @Status,
		StatusChangeDateTime = GETDATE()
		WHERE SuiteName = @SuiteName
	END
ELSE IF @Status IN ('S', 'P')	
	BEGIN
		UPDATE Suite SET Status = @Status,
		StatusChangeDateTime = GETDATE(),
		MaxExpectedExecutionEmailSent = NULL
		WHERE SuiteName = @SuiteName	
	END
END
