

CREATE PROC [dbo].[spGetNextTime]
@CurrentDateTime DATETIME,
@ScheduleID INT,
@NextRunDateTime DATETIME OUTPUT
AS
BEGIN
 	DECLARE @Mon BIT
	DECLARE @Tue BIT
	DECLARE @Wed BIT
	DECLARE @Thu BIT
	DECLARE @Fri BIT
	DECLARE @Sat BIT
	DECLARE @Sun BIT
	DECLARE @StartTime TIME(0)
	DECLARE @EndTime TIME(0)
	DECLARE @OccursEvery TIME(0)
	DECLARE @NextDateTime DATETIME = @CurrentDateTime
	DECLARE @NextTime TIME(0) = @CurrentDateTime
	DECLARE @TimeSet BIT = 0
	DECLARE @Loop BIT = 0
	DECLARE @days int
	DECLARE @TodayName VARCHAR(3)
	DECLARE @ScheduleTypeId INT
	DECLARE @ErrorMessage VARCHAR(1000)  

	SELECT @Mon = Mon,
	@Tue = Tue,
	@Wed = Wed,
	@Thu = Thu,
	@Fri = Fri,
	@Sat = Sat,
	@Sun = Sun,
	@StartTime = StartTime,
	@EndTime = EndTime,
	@OccursEvery = OccursEvery,
	@ScheduleTypeId = ScheduleTypeId
	FROM dbo.Schedule WHERE ScheduleID = @ScheduleID
-------------------------------------------------------------------------------
-- Error handling
-------------------------------------------------------------------------------
	IF (@Mon IS NULL AND
	@Tue IS NULL AND
	@Wed IS NULL AND
	@Thu IS NULL AND
	@Fri IS NULL AND
	@Sat IS NULL AND
	@Sun IS NULL)
	BEGIN
		SET @ErrorMessage = 'Schedule|day of the week has not been selected for.' + CAST(@ScheduleID AS VARCHAR(30));
		RAISERROR(@ErrorMessage, 16, 1);
	END
    
	IF @StartTime IS NULL
	BEGIN
		SET @ErrorMessage = 'Schedule|No start time has been specified.' + CAST(@ScheduleID AS VARCHAR(30))  
		RAISERROR(@ErrorMessage, 16, 1);
	END  

	IF @StartTime IS NOT NULL AND @EndTime  IS NOT NULL AND @OccursEvery IS NULL
	BEGIN
		SET @ErrorMessage = 'Schedule|OccursEvery has not been specified.' + CAST(@ScheduleID AS VARCHAR(30))  
		RAISERROR(@ErrorMessage, 16, 1);
	END  

-------------------------------------------------------------------------------
-- Calculate
-------------------------------------------------------------------------------
	IF @ScheduleTypeId = -1
	BEGIN
		SET @NextDateTime = '9999-12-31' -- Never to run again
	END
	ELSE IF @ScheduleTypeId = 1
	BEGIN
		SET @NextDateTime = CONVERT(DATETIME, (CONVERT(VARCHAR(10), @NextDateTime, 111) + ' ' + CONVERT(VARCHAR(30), @StartTime)))
		WHILE @Loop = 0
		BEGIN
			SET @TodayName = SUBSTRING(DATENAME(dw, @NextDateTime), 1 ,3)
			
			IF (@TodayName = 'Mon' AND @Mon = 1)
			   OR (@TodayName = 'Tue' AND @Tue = 1)
			   OR (@TodayName = 'Wed' AND @Wed = 1)
			   OR (@TodayName = 'Thu' AND @Thu = 1)
			   OR (@TodayName = 'Fri' AND @Fri = 1)
			   OR (@TodayName = 'Sat' AND @Sat = 1)
			   OR (@TodayName = 'Sun' AND @Sun = 1)
			BEGIN
				IF @CurrentDateTime <= @NextDateTime 
				BEGIN
					BREAK			
				END
			END
			
			IF( @EndTime IS NOT NULL AND @OccursEvery IS NOT NULL AND @TimeSet = 0)
			BEGIN
			    IF (DATEDIFF(SECOND,@StartTime, @NextTime) < 0)
			    BEGIN
					SET @NextDateTime = CONVERT(DATETIME, (CONVERT(VARCHAR(10), @NextDateTime, 111) + ' ' + CONVERT(VARCHAR(30), @StartTime)))			    
			    END
			    ELSE IF @NextTime BETWEEN @StartTime AND @EndTime
			    BEGIN
					SET @NextTime = DATEADD(SECOND,(DATEDIFF(SECOND,@StartTime, @NextTime)/ DATEDIFF(SECOND,0, @OccursEvery) + 1) * DATEDIFF(SECOND,0, @OccursEvery), @StartTime)
					SET @NextDateTime = CONVERT(DATETIME, (CONVERT(VARCHAR(10), @NextDateTime, 111) + ' ' + CONVERT(VARCHAR(30), @NextTime)))
				END
				
				IF (DATEDIFF(SECOND,@NextTime, @EndTime) < 0)
				BEGIN
					SET @NextDateTime = DATEADD(d,1,@NextDateTime)
					SET @NextDateTime = CONVERT(DATETIME, (CONVERT(VARCHAR(10), @NextDateTime, 111) + ' ' + CONVERT(VARCHAR(30), @StartTime)))
				END
				
				SET @TimeSet = 1
			END
			ELSE
			BEGIN
				SET @NextDateTime = DATEADD(d,1,@NextDateTime)
			END
		END
	END

    SET @NextRunDateTime = @NextDateTime
END