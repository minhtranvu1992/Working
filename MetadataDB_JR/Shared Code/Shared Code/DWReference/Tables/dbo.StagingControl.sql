CREATE TABLE [dbo].[StagingControl] (
    [StagingControlID]              INT           IDENTITY (1, 1) NOT NULL,
    [StagingPackagePath]            VARCHAR (200) NULL,
    [StagingPackageName]            VARCHAR (50)  NOT NULL,
    [ProcessType]                   VARCHAR (100) NULL,
    [SuiteID]                       INT           NULL,
    [ScheduleID]                    INT           NULL,
    [NextRunDateTime]               DATETIME      NULL,
    [SourceControlID]               INT           NOT NULL,
    [RemoteSourceControlID]         INT           NULL,
    [DelimiterChar]                 CHAR (1)      NULL,
    [StagingDestControlID]          INT           NULL,
    [TruncateStagingTable]          BIT           NULL,
    [StagingTable]                  VARCHAR (100) NULL,
    [SourceQuery]                   VARCHAR (MAX) NULL,
    [SourceQueryMapping]            VARCHAR (MAX) NULL,
    [MergeQuery]                    VARCHAR (MAX) NULL,
    [HasHeader]                     BIT           NULL,
    [HasFooter]                     BIT           NULL,
    [CheckExtractRowCount]          BIT           NULL,
    [RunAs32Bit]                    BIT           NULL,
    [Status]                        VARCHAR (1)   NULL,
    [StatusChangeDateTime]          DATETIME      NULL,
    [FailedCount]                   INT           NULL,
    [FailedCountEmailSent]          DATETIME      NULL,
    [MaxExpectedExecutionDuration]  TIME (0)      NULL,
    [MaxExpectedExecutionEmailSent] DATETIME      NULL,
	[MaxExpectedDurationBetweenFiles] TIME(0) NULL, 
    [LastStagingJobID]              INT           NULL,
    [LastExecutionTime]             DATETIME      NULL,
    [LastProcessedTime] DATETIME NULL, 
    CONSTRAINT [PK_StagingControl] PRIMARY KEY CLUSTERED ([StagingControlID] ASC),
    CONSTRAINT [FK_StagingControl_SourceControl] FOREIGN KEY ([RemoteSourceControlID]) REFERENCES [dbo].[SourceControl] ([SourceControlID]),
    CONSTRAINT [FK_StagingControl_SourceControl1] FOREIGN KEY ([StagingDestControlID]) REFERENCES [dbo].[SourceControl] ([SourceControlID]),
    CONSTRAINT [FK_StagingControl_Suite] FOREIGN KEY ([SuiteID]) REFERENCES [dbo].[Suite] ([SuiteID])
);








GO

CREATE TRIGGER [dbo].[StagingControl_ChangeTracking] on [dbo].[StagingControl] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[StagingControl]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'StagingControlID'
DECLARE @PKValueSelect nvarchar(1000)
 
-- date and user
SELECT @UserName = SYSTEM_USER , @UpdateDate = CONVERT(VARCHAR(8), GETDATE(), 112) + ' ' + CONVERT(VARCHAR(12), GETDATE(), 114)



-- Action
IF EXISTS (SELECT * FROM inserted)
BEGIN
	--SELECT  FROM inserted
	IF EXISTS (SELECT * FROM deleted)
	BEGIN
	--	SELECT  FROM deleted
		SELECT @Type = 'U'
	END
	ELSE
	BEGIN
		SELECT @Type = 'I'
	END
END
ELSE
BEGIN
	--SELECT  FROM deleted
	SELECT @Type = 'D'
END


INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'StagingControlID', CONVERT(NVARCHAR(MAX), d.StagingControlID), CONVERT(NVARCHAR(MAX),i.StagingControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.StagingControlID <> d.StagingControlID OR i.StagingControlID IS NULL AND d.StagingControlID IS NOT NULL OR i.StagingControlID IS NOT NULL AND d.StagingControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'StagingPackagePath', CONVERT(NVARCHAR(MAX), d.StagingPackagePath), CONVERT(NVARCHAR(MAX),i.StagingPackagePath),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.StagingPackagePath <> d.StagingPackagePath OR i.StagingPackagePath IS NULL AND d.StagingPackagePath IS NOT NULL OR i.StagingPackagePath IS NOT NULL AND d.StagingPackagePath IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'StagingPackageName', CONVERT(NVARCHAR(MAX), d.StagingPackageName), CONVERT(NVARCHAR(MAX),i.StagingPackageName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.StagingPackageName <> d.StagingPackageName OR i.StagingPackageName IS NULL AND d.StagingPackageName IS NOT NULL OR i.StagingPackageName IS NOT NULL AND d.StagingPackageName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'ProcessType', CONVERT(NVARCHAR(MAX), d.ProcessType), CONVERT(NVARCHAR(MAX),i.ProcessType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.ProcessType <> d.ProcessType OR i.ProcessType IS NULL AND d.ProcessType IS NOT NULL OR i.ProcessType IS NOT NULL AND d.ProcessType IS NULL
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'SuiteID', CONVERT(NVARCHAR(MAX), d.SuiteID), CONVERT(NVARCHAR(MAX),i.SuiteID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.SuiteID <> d.SuiteID OR i.SuiteID IS NULL AND d.SuiteID IS NOT NULL OR i.SuiteID IS NOT NULL AND d.SuiteID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'ScheduleID', CONVERT(NVARCHAR(MAX), d.ScheduleID), CONVERT(NVARCHAR(MAX),i.ScheduleID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.ScheduleID <> d.ScheduleID OR i.ScheduleID IS NULL AND d.ScheduleID IS NOT NULL OR i.ScheduleID IS NOT NULL AND d.ScheduleID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'SourceControlID', CONVERT(NVARCHAR(MAX), d.SourceControlID), CONVERT(NVARCHAR(MAX),i.SourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.SourceControlID <> d.SourceControlID OR i.SourceControlID IS NULL AND d.SourceControlID IS NOT NULL OR i.SourceControlID IS NOT NULL AND d.SourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'RemoteSourceControlID', CONVERT(NVARCHAR(MAX), d.RemoteSourceControlID), CONVERT(NVARCHAR(MAX),i.RemoteSourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.RemoteSourceControlID <> d.RemoteSourceControlID OR i.RemoteSourceControlID IS NULL AND d.RemoteSourceControlID IS NOT NULL OR i.RemoteSourceControlID IS NOT NULL AND d.RemoteSourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'DelimiterChar', CONVERT(NVARCHAR(MAX), d.DelimiterChar), CONVERT(NVARCHAR(MAX),i.DelimiterChar),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.DelimiterChar <> d.DelimiterChar OR i.DelimiterChar IS NULL AND d.DelimiterChar IS NOT NULL OR i.DelimiterChar IS NOT NULL AND d.DelimiterChar IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'StagingDestControlID', CONVERT(NVARCHAR(MAX), d.StagingDestControlID), CONVERT(NVARCHAR(MAX),i.StagingDestControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.StagingDestControlID <> d.StagingDestControlID OR i.StagingDestControlID IS NULL AND d.StagingDestControlID IS NOT NULL OR i.StagingDestControlID IS NOT NULL AND d.StagingDestControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'StagingTable', CONVERT(NVARCHAR(MAX), d.StagingTable), CONVERT(NVARCHAR(MAX),i.StagingTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.StagingTable <> d.StagingTable OR i.StagingTable IS NULL AND d.StagingTable IS NOT NULL OR i.StagingTable IS NOT NULL AND d.StagingTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'SourceQuery', CONVERT(NVARCHAR(MAX), d.SourceQuery), CONVERT(NVARCHAR(MAX),i.SourceQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.SourceQuery <> d.SourceQuery OR i.SourceQuery IS NULL AND d.SourceQuery IS NOT NULL OR i.SourceQuery IS NOT NULL AND d.SourceQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'SourceQueryMapping', CONVERT(NVARCHAR(MAX), d.SourceQueryMapping), CONVERT(NVARCHAR(MAX),i.SourceQueryMapping),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.SourceQueryMapping <> d.SourceQueryMapping OR i.SourceQueryMapping IS NULL AND d.SourceQueryMapping IS NOT NULL OR i.SourceQueryMapping IS NOT NULL AND d.SourceQueryMapping IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'MergeQuery', CONVERT(NVARCHAR(MAX), d.MergeQuery), CONVERT(NVARCHAR(MAX),i.MergeQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.MergeQuery <> d.MergeQuery OR i.MergeQuery IS NULL AND d.MergeQuery IS NOT NULL OR i.MergeQuery IS NOT NULL AND d.MergeQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'HasHeader', CONVERT(NVARCHAR(MAX), d.HasHeader), CONVERT(NVARCHAR(MAX),i.HasHeader),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.HasHeader <> d.HasHeader OR i.HasHeader IS NULL AND d.HasHeader IS NOT NULL OR i.HasHeader IS NOT NULL AND d.HasHeader IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'HasFooter', CONVERT(NVARCHAR(MAX), d.HasFooter), CONVERT(NVARCHAR(MAX),i.HasFooter),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.HasFooter <> d.HasFooter OR i.HasFooter IS NULL AND d.HasFooter IS NOT NULL OR i.HasFooter IS NOT NULL AND d.HasFooter IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'CheckExtractRowCount', CONVERT(NVARCHAR(MAX), d.CheckExtractRowCount), CONVERT(NVARCHAR(MAX),i.CheckExtractRowCount),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.CheckExtractRowCount <> d.CheckExtractRowCount OR i.CheckExtractRowCount IS NULL AND d.CheckExtractRowCount IS NOT NULL OR i.CheckExtractRowCount IS NOT NULL AND d.CheckExtractRowCount IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'RunAs32Bit', CONVERT(NVARCHAR(MAX), d.RunAs32Bit), CONVERT(NVARCHAR(MAX),i.RunAs32Bit),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.RunAs32Bit <> d.RunAs32Bit OR i.RunAs32Bit IS NULL AND d.RunAs32Bit IS NOT NULL OR i.RunAs32Bit IS NOT NULL AND d.RunAs32Bit IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'MaxExpectedExecutionDuration', CONVERT(NVARCHAR(MAX), d.MaxExpectedExecutionDuration), CONVERT(NVARCHAR(MAX),i.MaxExpectedExecutionDuration),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.MaxExpectedExecutionDuration <> d.MaxExpectedExecutionDuration OR i.MaxExpectedExecutionDuration IS NULL AND d.MaxExpectedExecutionDuration IS NOT NULL OR i.MaxExpectedExecutionDuration IS NOT NULL AND d.MaxExpectedExecutionDuration IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'MaxExpectedExecutionEmailSent', CONVERT(NVARCHAR(MAX), d.MaxExpectedExecutionEmailSent), CONVERT(NVARCHAR(MAX),i.MaxExpectedExecutionEmailSent),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.MaxExpectedExecutionEmailSent <> d.MaxExpectedExecutionEmailSent OR i.MaxExpectedExecutionEmailSent IS NULL AND d.MaxExpectedExecutionEmailSent IS NOT NULL OR i.MaxExpectedExecutionEmailSent IS NOT NULL AND d.MaxExpectedExecutionEmailSent IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.StagingControlID,d.StagingControlID)), 'TruncateStagingTable', CONVERT(NVARCHAR(MAX), d.TruncateStagingTable), CONVERT(NVARCHAR(MAX),i.TruncateStagingTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.StagingControlID = d.StagingControlID
WHERE i.TruncateStagingTable <> d.TruncateStagingTable OR i.TruncateStagingTable IS NULL AND d.TruncateStagingTable IS NOT NULL OR i.TruncateStagingTable IS NOT NULL AND d.TruncateStagingTable IS NULL