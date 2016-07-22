

--======================================--
-- JOB TEMPLATE					--
-- Press Ctrl-Shift-M to enter data	--
--======================================--


USE [msdb]
GO

/****** Object:  Job [SCA Data Load]    Script Date: 3/07/2014 11:52:24 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 3/07/2014 11:52:25 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'<DW_Label, varchar(50), DW>' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'<DW_Label, varchar(50), DW>'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'<DW_Label, varchar(50), DW> Data Load', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@description=N'Run''s the full staging, extract, delivery and summary jobs for building the <DW_Label, varchar(50), DW>', 
		@category_name=N'<DW_Label, varchar(50), DW>', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Staging Manager]    Script Date: 3/07/2014 11:52:27 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Staging Manager', 
		@step_id=1, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@subsystem=N'SSIS', 
		@command=N'/DTS "\"\MSDB\<Environment, varchar(50), Dev>\Core\StagingManagerDynamic\"" /SERVER <SSIS_Server, varchar(50), > /CHECKPOINTING OFF /SET "\"\package.Variables[ConnStr_ETLReference].Value\"";"\"Data Source=<DW_Server, varchar(50), >;Initial Catalog=<DW_Label, varchar(50), DW>Reference;Provider=SQLNCLI11.1;Integrated Security=SSPI\"" /REPORTING E', 
		@database_name=N'master' 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extract Manager Group 1]    Script Date: 3/07/2014 11:52:27 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extract Manager Group 1', 
		@step_id=2, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@subsystem=N'SSIS', 
		@command=N'/DTS "\"\MSDB\<Environment, varchar(50), Dev>\Core\ExtractManagerDynamic\"" /SERVER <SSIS_Server, varchar(50), > /CHECKPOINTING OFF /SET "\"\package.Variables[ConnStr_ETLReference].Value\"";"\"Data Source=<DW_Server, varchar(50), >;Initial Catalog=<DW_Label, varchar(50), DW>Reference;Provider=SQLNCLI11.1;Integrated Security=SSPI\"" /SET "\"\package.Variables[ExecutionOrderGroup].Value\"";1 /REPORTING E', 
		@database_name=N'master'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delivery Manager]    Script Date: 3/07/2014 11:52:27 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delivery Manager', 
		@step_id=3, 
		@on_success_action=3, 
		@on_fail_action=2, 
	     @subsystem=N'SSIS', 
		@command=N'/DTS "\"\MSDB\<Environment, varchar(50), Dev>\Core\DeliveryManagerDynamic\"" /SERVER <SSIS_Server, varchar(50), > /CHECKPOINTING OFF /SET "\"\package.Variables[ScheduleType].Value\"";Daily /SET "\"\package.Variables[ConnStr_ETLReference].Value\"";"\"Data Source=<DW_Server, varchar(50), >;Initial Catalog=<DW_Label, varchar(50), DW>Reference;Provider=SQLNCLI11.1;Integrated Security=SSPI\"" /REPORTING E', 
		@database_name=N'master'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Summary Mamanger]    Script Date: 3/07/2014 11:52:28 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Summary Mamanger', 
		@step_id=4, 
		@on_success_action=3, 
		@on_fail_action=2, 
	     @subsystem=N'SSIS', 
		@command=N'/DTS "\MSDB\<Environment, varchar(50), Dev>\Core\SummaryManagerDynamic" /SERVER <SSIS_Server, varchar(50), > /CHECKPOINTING OFF /SET "\package.Variables[ConnStr_ETLReference].Value";"\"Data Source=<DW_Server, varchar(50), >;Initial Catalog=<DW_Label, varchar(50), DW>Reference;Provider=SQLNCLI11.1;Integrated Security=SSPI\"" /SET "\package.Variables[ScheduleType].Value";Daily /REPORTING E', 
		@database_name=N'master'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extract Manager Group 2]    Script Date: 3/07/2014 11:52:28 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extract Manager Group 2', 
		@step_id=5, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@subsystem=N'SSIS', 
		@command=N'/DTS "\"\MSDB\<Environment, varchar(50), Dev>\Core\ExtractManagerDynamic\"" /SERVER <SSIS_Server, varchar(50), > /CHECKPOINTING OFF /SET "\"\package.Variables[ConnStr_ETLReference].Value\"";"\"Data Source=<DW_Server, varchar(50), >;Initial Catalog=<DW_Label, varchar(50), DW>Reference;Provider=SQLNCLI11.1;Integrated Security=SSPI\"" /SET "\"\package.Variables[ExecutionOrderGroup].Value\"";2 /REPORTING E', 
		@database_name=N'master'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@active_start_date=20130904, 
		@active_end_date=99991231, 
		@active_end_time=235959 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [SCA ETL Emails Daily]    Script Date: 3/07/2014 11:52:29 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'<DW_Label, varchar(50), DW> ETL Emails Daily', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@description=N'No description available.', 
		@category_name=N'<DW_Label, varchar(50), DW>', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Emails]    Script Date: 3/07/2014 11:52:32 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Emails', 
		@step_id=1, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[spSendEmailChecker] ''Daily''', 
		@database_name=N'<DW_Label, varchar(50), DW>Reference', 
		@output_file_name=N'<JobLog_Folder, varchar(50), d:\JobLogs>\SCAETLEmailsDaily______STEP_$(ESCAPE_SQUOTE(STEPID))_Emails.txt'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=1, 
		@active_start_date=20130204, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [SCA ETL Emails Hourly]    Script Date: 3/07/2014 11:52:33 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'<DW_Label, varchar(50), DW> ETL Emails Hourly', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@description=N'No description available.', 
		@category_name=N'<DW_Label, varchar(50), DW>', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Emails]    Script Date: 3/07/2014 11:52:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Emails', 
		@step_id=1, 
		@on_success_action=1, 
		@on_fail_action=2, 
	     @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[spSendEmailChecker] ''Hourly''', 
		@database_name=N'<DW_Label, varchar(50), DW>Reference', 
		@output_file_name=N'<JobLog_Folder, varchar(50), d:\JobLogs>\SCAETLEmailsHourly______STEP_$(ESCAPE_SQUOTE(STEPID))_Emails.txt'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@active_start_date=20130204, 
		@active_end_date=99991231, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


