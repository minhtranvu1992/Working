-- =============================================
-- Author:		Olof Szymczak
-- Create date: 2012-02-17
-- Description:	Check if the cubes need to be built
-- used as a task in the sql job
-- =============================================
CREATE PROCEDURE [dbo].[spCheckBuildCube] 
AS
BEGIN
	DECLARE @DeliveryTime DATETIME 
	DECLARE @CubeTime DATETIME
	DECLARE @SqlJobServer NVARCHAR(100)
	DECLARE @sqlstmt nvarchar(max)  
	DECLARE @IsRunning INT 
	SET @IsRunning =1 
	SELECT @DeliveryTime = MAX(EndTime)
	FROM dbo.DeliveryExecutionLog
	WHERE SuccessFlag = 1 
	SELECT @CubeTime = MAX(EndTime)
	FROM dbo.CubeExecutionLog
	WHERE SuccessFlag = 1
	SELECT @SqlJobServer = [ConfiguredValue]
    FROM [dbo].[SSISConfiguration]
	WHERE [ConfigurationFilter] = 'ServerSqlJob'

    ---- check whether any delivery package ran after the last cube process
	DECLARE @RESULT1 VARCHAR(10) =CASE WHEN ISNULL(@DeliveryTime, '1900-01-01') < ISNULL(@CubeTime , '1900-01-01')
	                              THEN 'NO' ELSE 'YES' END
	
    ----- Check for the cube built windows	
	dECLARE @RESULT2 VARCHAR(10) = CASE WHEN (CAST(getdate() as time) between '05:30:00' and '9:00:30'
		                           or CAST(getdate() as time) between '11:00:00' and '13:00:30')
		                            THEN 'YES'
		                           ELSE 'NO' END
		
	
	IF (@RESULT1 ='YES' AND @RESULT2 ='YES')
	BEGIN
	SET @sqlstmt = 'select @count = count(1) from OPENROWSET(''SQLNCLI'',''server='+@SqlJobServer+';trusted_Connection=yes;'',''SELECT 1 
			          FROM msdb.dbo.sysjobs J 
                      INNER JOIN msdb.dbo.sysjobactivity A ON A.job_id=J.job_id 
                      WHERE J.name=N''''Regional Distribution ETL Cube Process'''' 
                      AND A.run_requested_date IS NOT NULL 
                      AND A.stop_execution_date IS NULL'') '
		
		
		
	       	EXECUTE sp_executesql @sqlstmt, N'@count int OUTPUT', @count = @IsRunning output                      
           -- Execute the cube refresh job if the Regional Distribution ETL Cube Process is not executing currently
			IF @IsRunning = 0 
			BEGIN
				EXEC msdb.dbo.sp_start_job @job_name = 'Regional Distribution ETL Cube Process', @server_name = @SqlJobServer
			END
	END
END
