

CREATE PROCEDURE [dbo].[uspScriptDWReferenceLayer]
AS
BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

	BEGIN TRY

		DECLARE @SQL_Header AS VARCHAR(MAX)
		DECLARE @SQL_Footer AS VARCHAR(MAX)
		DECLARE @DWReference_ModelDB AS VARCHAR(MAX)
		DECLARE @DWReference_TargetDB AS VARCHAR(MAX)

		SET @DWReference_ModelDB = (SELECT dbo.fnGetParameterValue('DWReference_ModelDB') )
		SET @DWReference_TargetDB = (SELECT dbo.fnGetParameterValue('DWReference_TargetDB') )

		SELECT @SQL_Header = '
USE Master
GO

PRINT N''Dropping Database ' + @DWReference_ModelDB + '...''
GO

IF (DB_ID(N''' + @DWReference_ModelDB + ''') IS NOT NULL) 
BEGIN
	ALTER DATABASE [' + @DWReference_ModelDB + ']
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [' + @DWReference_ModelDB + '];
END

GO

PRINT N''Creating Database ' + @DWReference_ModelDB + '...''
GO

CREATE DATABASE [' + @DWReference_ModelDB + '] 
GO

USE ' + @DWReference_ModelDB + '
GO

PRINT N''Creating Table SourceControl...''
GO

CREATE TABLE [dbo].[SourceControl](
	[SourceControlID] [int] NULL,
	[SourceName] [varchar](50) NOT NULL,
	[SourceType] [varchar](100) NULL,
	[SourceTypeID] [int] NULL,
	[AccessWindowStartMins] [int] NULL,
	[AccessWindowEndMins] [int] NULL,
	[SSISConfigurationID] [int] NULL,
 CONSTRAINT [PK_SourceControl] PRIMARY KEY CLUSTERED 
(
	[SourceName] ASC
)
) 

GO

PRINT N''Creating Table Suite...''
GO



CREATE TABLE [dbo].[Suite](
	[SuiteID] [int] NULL,
	[SuiteName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Suite] PRIMARY KEY CLUSTERED 
(
	[SuiteName] ASC
)
) 

GO

PRINT N''Creating Table DeliveryControl...''
GO


CREATE TABLE [dbo].[DeliveryControl](
	[DeliveryControlID] [int] NULL,
	[DeliveryPackageName] [varchar](100) NOT NULL,
	[ProcessType] [varchar](100) NULL,
	[DeliveryTable] [varchar](100) NULL,
	[ExtractTable] [varchar](100) NULL,
	[SourceIdentifier] [varchar](100) NULL,
	[ExecutionOrder] [int] NOT NULL,
	[InsertOnly] [bit] NULL,
 CONSTRAINT [PK_DeliveryControl] PRIMARY KEY CLUSTERED 
(
	[DeliveryPackageName] ASC
)
)
GO

PRINT N''Creating Table ExtractControl...''
GO



CREATE TABLE [dbo].[ExtractControl](
	[ExtractControlID] [int] NULL,
	[ExtractPackageName] [varchar](50) NOT NULL,
	[ExtractPackagePath] [varchar](200) NOT NULL,
	[ProcessType] [varchar](50) NULL,
	[SuiteName] [varchar](50) NOT NULL,
	[SuiteID] [int] NULL,
	[SourceQuery] VARCHAR(MAX),
	[SourceQueryMapping] VARCHAR(MAX),
	[ExtractTable] [varchar](50) NULL,
	[ExecutionOrder] INT NOT NULL, 
	[ExecutionOrderGroup] INT NOT NULL, 
	[ExtractStartTime] DATETIME NOT NULL, 
	[LastExtractJobID] INT NOT NULL,
 CONSTRAINT [PK_ExtractControl] PRIMARY KEY CLUSTERED 
(
	[SuiteName] ASC,
	[ExtractPackageName] ASC
)
)
GO

PRINT N''Creating Table SummaryControl...''
GO



CREATE TABLE [dbo].[SummaryControl](
	[SummaryControlID] [int] NULL,
	[SummaryPackageName] [varchar](100) NOT NULL,
	[SummaryTableName] [varchar](100) NULL,
	[ScheduleType] [varchar](50) NOT NULL,
	[SourceQuery] [varchar](1000) NULL,
	[Type] [varchar](50) NOT NULL,
	[SourceControlID] [int] NOT NULL,
	[LastSummaryJobID] [int] NOT NULL,
	[ExecutionOrder] [int] NOT NULL,
 CONSTRAINT [PK_SummaryControl] PRIMARY KEY CLUSTERED 
(
	[SummaryPackageName] ASC
)
) 
GO

PRINT N''Creating Table StagingControl...''
GO


CREATE TABLE [dbo].[StagingControl](
	[StagingControlID] [int] NULL,
	[StagingPackagePath] [varchar](200) NULL,
	[StagingPackageName] [varchar](50) NOT NULL,
	[ProcessType] [varchar](100) NULL,
	[SuiteName] [varchar](50) NOT NULL,
	[SuiteID] [int] NULL,
	[SourceName] [varchar](50) NOT NULL,
	[SourceControlID] [int] NULL,
	[RemoteSourceName] [varchar](50) NULL,
	[RemoteSourceControlID] [int] NULL,
	[DelimiterChar] [char](1) NULL,
	[FlatFileFormatString] [varchar](200) NULL,
	[HeaderCheckString] [varchar](max) NULL,
	[StagingDest] [varchar](50) NULL,
	[StagingDestControlID] [int] NULL,
	[StagingTable] [varchar](100) NULL,
	[SourceQuery] [varchar](max) NULL,
	[SourceQueryMapping] [varchar](max) NULL,
	[MergeQuery] [varchar](max) NULL,
	[HasHeader] [bit] NULL,
	[HasFooter] [bit] NULL,
 CONSTRAINT [PK_StagingControl] PRIMARY KEY CLUSTERED 
(
	[StagingPackageName] ASC, [SuiteName] ASC, [SourceName] ASC
)
)
GO

'


		SELECT @SQL_Footer = '
PRINT N''Updating Table Suite...''
GO


UPDATE [dbo].[Suite]
	SET SuiteID = Suite.SuiteID
FROM
	[dbo].[Suite] Suite_Model
	INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[Suite] Suite
		ON Suite_Model.SuiteName = Suite.SuiteName
GO

DECLARE @MaxSuiteID AS Integer 
SELECT @MaxSuiteID = (SELECT ISNULL(MAX(SuiteID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[Suite])

UPDATE [dbo].[Suite]
	SET SuiteID = Suite_NewIds.NewSuiteID
FROM [dbo].[Suite] Suite_Model
	INNER JOIN 
	(
	SELECT 
		Suite_Model.SuiteName,
		(@MaxSuiteID + Row_Number() OVER (ORDER BY Suite_Model.SuiteName)) AS NewSuiteID
	FROM 
		[dbo].[Suite] Suite_Model
	WHERE 
		Suite_Model.SuiteID IS NULL
	) Suite_NewIds
		ON Suite_Model.SuiteName = Suite_NewIds.SuiteName
GO		


PRINT N''Updating Table SourceControl...''
GO


UPDATE [dbo].[SourceControl]
	SET SourceControlID = SourceControl.SourceControlID
		,SSISConfigurationID = SourceControl.SSISConfigurationID
		,SourceTypeID = SourceType.SourceTypeID
FROM
	[dbo].[SourceControl] SourceControl_Model
	INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[SourceControl] SourceControl
		ON SourceControl_Model.SourceName = SourceControl.SourceName
     INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[SourceType] SourceType
		ON SourceControl_Model.SourceType = SourceType.SourceTypeName
GO

DECLARE @MaxSourceControlID AS Integer 
SELECT @MaxSourceControlID = (SELECT ISNULL(MAX(SourceControlID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[SourceControl])

UPDATE [dbo].[SourceControl]
	SET SourceControlID = SourceControl_NewIds.NewSourceControlID
FROM [dbo].[SourceControl] SourceControl_Model
	INNER JOIN 
	(
	SELECT 
		SourceControl_Model.SourceName,
		(@MaxSourceControlID + Row_Number() OVER (ORDER BY SourceControl_Model.SourceName)) AS NewSourceControlID
	FROM 
		[dbo].[SourceControl] SourceControl_Model
	WHERE 
		SourceControl_Model.SourceControlID IS NULL
	) SourceControl_NewIds
		ON SourceControl_Model.SourceName = SourceControl_NewIds.SourceName
GO		


PRINT N''Updating Table ExtractControl...''
GO


UPDATE [dbo].[ExtractControl]
	SET SuiteID = Suite_Model.SuiteID
FROM
	[dbo].[ExtractControl] ExtractControl_Model
	INNER JOIN [dbo].[Suite] Suite_Model
		ON ExtractControl_Model.SuiteName = Suite_Model.SuiteName 
GO

UPDATE [dbo].[ExtractControl]
	SET	ExtractControlID = ExtractControl.ExtractControlID
		,ExtractStartTime = ExtractControl.ExtractStartTime
		,LastExtractJobID = ExtractControl.LastExtractJobID
FROM
	[dbo].[ExtractControl] ExtractControl_Model
	INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[ExtractControl] ExtractControl
		ON ExtractControl_Model.ExtractPackageName = ExtractControl.ExtractPackageName
		AND ExtractControl_Model.SuiteID = ExtractControl.SuiteID
GO

DECLARE @MaxExtractControlID AS Integer 
SELECT @MaxExtractControlID = (SELECT ISNULL(MAX(ExtractControlID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[ExtractControl])

UPDATE [dbo].[ExtractControl]
	SET ExtractControlID = ExtractControl_NewIds.NewExtractControlID
FROM [dbo].[ExtractControl] ExtractControl_Model
	INNER JOIN 
	(SELECT 
		ExtractControl_Model.ExtractPackageName,
		ExtractControl_Model.SuiteID,	
		(@MaxExtractControlID + Row_Number() OVER (ORDER BY ExtractControl_Model.SuiteID, ExtractControl_Model.ExtractPackageName)) AS NewExtractControlID
	FROM 
		[dbo].[ExtractControl] ExtractControl_Model
	WHERE 
		ExtractControl_Model.ExtractControlID IS NULL
	) ExtractControl_NewIds
		ON ExtractControl_Model.ExtractPackageName = ExtractControl_NewIds.ExtractPackageName
		AND ExtractControl_Model.SuiteID = ExtractControl_NewIds.SuiteID
GO

PRINT N''Updating Table DeliveryControl...''
GO

UPDATE [dbo].[DeliveryControl]
	SET DeliveryControlID = DeliveryControl.DeliveryControlID
FROM
	[dbo].[DeliveryControl] DeliveryControl_Model
	INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[DeliveryControl] DeliveryControl
		ON DeliveryControl_Model.DeliveryPackageName = DeliveryControl.DeliveryPackageName
GO

DECLARE @MaxDeliveryControlID AS Integer 
SELECT @MaxDeliveryControlID = (SELECT ISNULL(MAX(DeliveryControlID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[DeliveryControl])

UPDATE [dbo].[DeliveryControl]
	SET DeliveryControlID = DeliveryControl_NewIds.NewDeliveryControlID
FROM [dbo].[DeliveryControl] DeliveryControl_Model
	INNER JOIN 
	(
	SELECT 
		DeliveryControl_Model.DeliveryPackageName,
		(@MaxDeliveryControlID + Row_Number() OVER (ORDER BY DeliveryControl_Model.DeliveryPackageName)) AS NewDeliveryControlID
	FROM 
		[dbo].[DeliveryControl] DeliveryControl_Model
	WHERE 
		DeliveryControl_Model.DeliveryControlID IS NULL
	) DeliveryControl_NewIds
		ON DeliveryControl_Model.DeliveryPackageName = DeliveryControl_NewIds.DeliveryPackageName
GO

PRINT N''Updating Table SummaryControl...''
GO

UPDATE [dbo].[SummaryControl]
	SET SummaryControlID = SummaryControl.SummaryControlID
		,SourceControlID = SummaryControl.SourceControlID
		,LastSummaryJobID = SummaryControl.LastSummaryJobID
		,ScheduleType = SummaryControl.ScheduleType
FROM
	[dbo].[SummaryControl] SummaryControl_Model
	INNER JOIN [' + @DWReference_TargetDB + '].[dbo].[SummaryControl] SummaryControl
		ON SummaryControl_Model.SummaryPackageName = SummaryControl.SummaryPackageName
GO

DECLARE @MaxSummaryControlID AS Integer 
DECLARE @SummarySourceControlID AS Integer
SELECT @MaxSummaryControlID = (SELECT ISNULL(MAX(SummaryControlID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[SummaryControl])
SELECT @SummarySourceControlID = (SELECT MAX(SourceControlID) FROM [' + @DWReference_TargetDB + '].[dbo].[SourceControl] WHERE SourceName = ''DWData'')

UPDATE [dbo].[SummaryControl]
	SET SummaryControlID = SummaryControl_NewIds.NewSummaryControlID
		,SourceControlID = @SummarySourceControlID
FROM [dbo].[SummaryControl] SummaryControl_Model
	INNER JOIN 
	(
	SELECT 
		SummaryControl_Model.SummaryPackageName,
		(@MaxSummaryControlID + Row_Number() OVER (ORDER BY SummaryControl_Model.SummaryPackageName)) AS NewSummaryControlID
	FROM 
		[dbo].[SummaryControl] SummaryControl_Model
	WHERE 
		SummaryControl_Model.SummaryControlID IS NULL
	) SummaryControl_NewIds
		ON SummaryControl_Model.SummaryPackageName = SummaryControl_NewIds.SummaryPackageName
		
GO

PRINT N''Updating Table StagingControl...''
GO

UPDATE [dbo].[StagingControl]
	SET 
	     StagingControlID = StagingControl.StagingControlID
		,SuiteID = Suite.SuiteID
		,SourceControlID = SourceControl.SourceControlID
		,RemoteSourceControlID = RemoteSourceControl.SourceControlID
		,StagingDestControlID = DestSourceControl.SourceControlID

FROM
	[dbo].[StagingControl] StagingControl_Model
	LEFT JOIN [dbo].SourceControl SourceControl
	   ON StagingControl_Model.SourceName = SourceControl.SourceName
	LEFT JOIN [dbo].SourceControl RemoteSourceControl
	   ON StagingControl_Model.RemoteSourceName = RemoteSourceControl.SourceName
	LEFT JOIN [dbo].SourceControl DestSourceControl
	   ON StagingControl_Model.StagingDest = DestSourceControl.SourceName
	LEFT JOIN [dbo].Suite Suite 
	   ON StagingControl_Model.SuiteName = Suite.SuiteName
	LEFT JOIN [' + @DWReference_TargetDB + '].[dbo].[StagingControl] StagingControl
		ON StagingControl_Model.StagingPackageName = StagingControl.StagingPackageName
		AND Suite.SuiteID = StagingControl.SuiteID
		AND SourceControl.SourceControlID = StagingControl.SourceControlID
GO

DECLARE @MaxStagingControlID AS Integer 
DECLARE @StagingSourceControlID AS Integer
SELECT @MaxStagingControlID = (SELECT ISNULL(MAX(StagingControlID),0) FROM [' + @DWReference_TargetDB + '].[dbo].[StagingControl])


UPDATE [dbo].[StagingControl]
	SET StagingControlID = StagingControl_NewIds.NewStagingControlID
FROM [dbo].[StagingControl] StagingControl_Model
	INNER JOIN 
	(
	SELECT 
		StagingControl_Model.StagingPackageName,
		StagingControl_Model.SuiteName,
		StagingControl_Model.SourceName,
		(@MaxStagingControlID + Row_Number() OVER (ORDER BY StagingControl_Model.StagingPackageName, StagingControl_Model.SuiteName, StagingControl_Model.SourceName)) AS NewStagingControlID
	FROM 
		[dbo].[StagingControl] StagingControl_Model
	WHERE 
		StagingControl_Model.StagingControlID IS NULL
	) StagingControl_NewIds
		ON StagingControl_Model.StagingPackageName = StagingControl_NewIds.StagingPackageName
		AND StagingControl_Model.SuiteName = StagingControl_NewIds.SuiteName 
		AND StagingControl_Model.SourceName = StagingControl_NewIds.SourceName
		
GO



		
'		


		EXEC dbo.udpLongPrint @SQL_Header
		EXEC [dbo].[uspScriptDWReferenceSourceRecords]
		EXEC [dbo].[uspScriptDWReferenceSuiteRecords]
		EXEC [dbo].[uspScriptDWReferenceExtractRecords]
		EXEC [dbo].[uspScriptDWReferenceDeliveryRecords]
		EXEC [dbo].[uspScriptDWReferenceSummaryRecords]
		EXEC [dbo].[uspScriptDWReferenceStagingRecords]
		EXEC dbo.udpLongPrint @SQL_Footer



	END TRY

	BEGIN CATCH
		/* rollback transaction if there is open transaction */
		IF @@TRANCOUNT > 0	ROLLBACK TRANSACTION

		/* throw the catched error to trigger the error in SSIS package */
		DECLARE @ErrorMessage NVARCHAR(4000),
				@ErrorNumber INT,
				@ErrorSeverity INT,
				@ErrorState INT,
				@ErrorLine INT,
				@ErrorProcedure NVARCHAR(200)

		/* Assign variables to error-handling functions that capture information for RAISERROR */
		SELECT  @ErrorNumber = ERROR_NUMBER(), @ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(), @ErrorLine = ERROR_LINE(),
			@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-')

		/* Building the message string that will contain original error information */
		SELECT  @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, '
		 + 'Message: ' + ERROR_MESSAGE()

		/* Raise an error: msg_str parameter of RAISERROR will contain the original error information */
		RAISERROR (@ErrorMessage, @ErrorSeverity, 1, @ErrorNumber,
			@ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine)
	END CATCH

	--Finally Section
	/* clean up the temporary table */

END








