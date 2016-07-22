CREATE TABLE [dbo].[ExtractControl] (
    [ExtractControlID]              INT            IDENTITY (1, 1) NOT NULL,
    [ExtractPackageName]            VARCHAR (50)   NOT NULL,
    [ExtractPackagePath]            VARCHAR (200)  NOT NULL,
    [ProcessType]                   VARCHAR (50)   NULL,
    [SourceControlID]               INT            NULL,
    [DestinationControlID]          INT            NULL,
    [SuiteID]                       INT            NULL,
    [CompanySuiteID]                INT            NULL,
    [ScheduleID]                    INT            NULL,
    [NextRunDateTime]               DATETIME       NULL,
    [SourceQuery]                   VARCHAR (MAX)  NULL,
    [SourceQueryMapping]            VARCHAR (MAX)  NULL,
    [TruncateExtractTable]          BIT            NULL,
    [ExtractTable]                  VARCHAR (50)   NULL,
    [ExecutionOrder]                INT            NOT NULL,
    [ExecutionOrderGroup]           INT            NOT NULL,
    [ConnectionCheckQuery]          VARCHAR (1000) NULL,
    [ConnectionCheckResult]         INT            NULL,
    [CheckConnection]               BIT            NULL,
    [DataCurrencyCheckQuery]        VARCHAR (1000) NULL,
    [DataCurrencyCheckResult]       INT            NULL,
    [CheckDataCurrency]             BIT            NULL,
    [RunAs32bit]                    BIT            CONSTRAINT [DF_ExtractControl_RunAs32bit] DEFAULT ((1)) NULL,
    [ExtractStartTime]              DATETIME       CONSTRAINT [DF_ExtractControl_ExtractStartTime] DEFAULT ('1900-01-01 00:00:00') NOT NULL,
    [Status]                        VARCHAR (1)    NULL,
    [StatusChangeDateTime]          DATETIME       NULL,
    [LastExtractJobID]              INT            CONSTRAINT [DF_ExtractControl_LastExtractJobID] DEFAULT ((0)) NOT NULL,
    [CheckExtractRowCount]          BIT            NULL,
    [FailedCount]                   INT            NULL,
    [FailedCountEmailSent]          DATETIME       NULL,
    [MaxExpectedExecutionDuration]  TIME (0)       NULL,
    [MaxExpectedExecutionEmailSent] DATETIME       NULL,
    CONSTRAINT [PK_ExtractControl] PRIMARY KEY CLUSTERED ([ExtractControlID] ASC),
    CONSTRAINT [FK_ExtractControl_Schedule] FOREIGN KEY ([ScheduleID]) REFERENCES [dbo].[Schedule] ([ScheduleID]),
    CONSTRAINT [FK_ExtractControl_SourceControl] FOREIGN KEY ([SourceControlID]) REFERENCES [dbo].[SourceControl] ([SourceControlID]),
    CONSTRAINT [FK_ExtractControl_SourceControl1] FOREIGN KEY ([DestinationControlID]) REFERENCES [dbo].[SourceControl] ([SourceControlID]),
    CONSTRAINT [FK_ExtractControl_Suite] FOREIGN KEY ([SuiteID]) REFERENCES [dbo].[Suite] ([SuiteID]),
    CONSTRAINT [IX_ExtractControl] UNIQUE NONCLUSTERED ([ExtractPackageName] ASC, [SuiteID] ASC, [ExecutionOrderGroup] ASC, [SourceControlID] ASC)
);








GO

CREATE TRIGGER [dbo].[ExtractControl_ChangeTracking] on [dbo].[ExtractControl] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[ExtractControl]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'ExtractControlID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExtractControlID', CONVERT(NVARCHAR(MAX), d.ExtractControlID), CONVERT(NVARCHAR(MAX),i.ExtractControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExtractControlID <> d.ExtractControlID OR i.ExtractControlID IS NULL AND d.ExtractControlID IS NOT NULL OR i.ExtractControlID IS NOT NULL AND d.ExtractControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExtractPackageName', CONVERT(NVARCHAR(MAX), d.ExtractPackageName), CONVERT(NVARCHAR(MAX),i.ExtractPackageName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExtractPackageName <> d.ExtractPackageName OR i.ExtractPackageName IS NULL AND d.ExtractPackageName IS NOT NULL OR i.ExtractPackageName IS NOT NULL AND d.ExtractPackageName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExtractPackagePath', CONVERT(NVARCHAR(MAX), d.ExtractPackagePath), CONVERT(NVARCHAR(MAX),i.ExtractPackagePath),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExtractPackagePath <> d.ExtractPackagePath OR i.ExtractPackagePath IS NULL AND d.ExtractPackagePath IS NOT NULL OR i.ExtractPackagePath IS NOT NULL AND d.ExtractPackagePath IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ProcessType', CONVERT(NVARCHAR(MAX), d.ProcessType), CONVERT(NVARCHAR(MAX),i.ProcessType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ProcessType <> d.ProcessType OR i.ProcessType IS NULL AND d.ProcessType IS NOT NULL OR i.ProcessType IS NOT NULL AND d.ProcessType IS NULL
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'SourceControlID', CONVERT(NVARCHAR(MAX), d.SourceControlID), CONVERT(NVARCHAR(MAX),i.SourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.SourceControlID <> d.SourceControlID OR i.SourceControlID IS NULL AND d.SourceControlID IS NOT NULL OR i.SourceControlID IS NOT NULL AND d.SourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'DestinationControlID', CONVERT(NVARCHAR(MAX), d.DestinationControlID), CONVERT(NVARCHAR(MAX),i.DestinationControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.DestinationControlID <> d.DestinationControlID OR i.DestinationControlID IS NULL AND d.DestinationControlID IS NOT NULL OR i.DestinationControlID IS NOT NULL AND d.DestinationControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'SuiteID', CONVERT(NVARCHAR(MAX), d.SuiteID), CONVERT(NVARCHAR(MAX),i.SuiteID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.SuiteID <> d.SuiteID OR i.SuiteID IS NULL AND d.SuiteID IS NOT NULL OR i.SuiteID IS NOT NULL AND d.SuiteID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'CompanySuiteID', CONVERT(NVARCHAR(MAX), d.CompanySuiteID), CONVERT(NVARCHAR(MAX),i.CompanySuiteID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.CompanySuiteID <> d.CompanySuiteID OR i.CompanySuiteID IS NULL AND d.CompanySuiteID IS NOT NULL OR i.CompanySuiteID IS NOT NULL AND d.CompanySuiteID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ScheduleID', CONVERT(NVARCHAR(MAX), d.ScheduleID), CONVERT(NVARCHAR(MAX),i.ScheduleID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ScheduleID <> d.ScheduleID OR i.ScheduleID IS NULL AND d.ScheduleID IS NOT NULL OR i.ScheduleID IS NOT NULL AND d.ScheduleID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'SourceQuery', CONVERT(NVARCHAR(MAX), d.SourceQuery), CONVERT(NVARCHAR(MAX),i.SourceQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.SourceQuery <> d.SourceQuery OR i.SourceQuery IS NULL AND d.SourceQuery IS NOT NULL OR i.SourceQuery IS NOT NULL AND d.SourceQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'SourceQueryMapping', CONVERT(NVARCHAR(MAX), d.SourceQueryMapping), CONVERT(NVARCHAR(MAX),i.SourceQueryMapping),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.SourceQueryMapping <> d.SourceQueryMapping OR i.SourceQueryMapping IS NULL AND d.SourceQueryMapping IS NOT NULL OR i.SourceQueryMapping IS NOT NULL AND d.SourceQueryMapping IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'TruncateExtractTable', CONVERT(NVARCHAR(MAX), d.TruncateExtractTable), CONVERT(NVARCHAR(MAX),i.TruncateExtractTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.TruncateExtractTable <> d.TruncateExtractTable OR i.TruncateExtractTable IS NULL AND d.TruncateExtractTable IS NOT NULL OR i.TruncateExtractTable IS NOT NULL AND d.TruncateExtractTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExtractTable', CONVERT(NVARCHAR(MAX), d.ExtractTable), CONVERT(NVARCHAR(MAX),i.ExtractTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExtractTable <> d.ExtractTable OR i.ExtractTable IS NULL AND d.ExtractTable IS NOT NULL OR i.ExtractTable IS NOT NULL AND d.ExtractTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExecutionOrder', CONVERT(NVARCHAR(MAX), d.ExecutionOrder), CONVERT(NVARCHAR(MAX),i.ExecutionOrder),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExecutionOrder <> d.ExecutionOrder OR i.ExecutionOrder IS NULL AND d.ExecutionOrder IS NOT NULL OR i.ExecutionOrder IS NOT NULL AND d.ExecutionOrder IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ExecutionOrderGroup', CONVERT(NVARCHAR(MAX), d.ExecutionOrderGroup), CONVERT(NVARCHAR(MAX),i.ExecutionOrderGroup),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ExecutionOrderGroup <> d.ExecutionOrderGroup OR i.ExecutionOrderGroup IS NULL AND d.ExecutionOrderGroup IS NOT NULL OR i.ExecutionOrderGroup IS NOT NULL AND d.ExecutionOrderGroup IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ConnectionCheckQuery', CONVERT(NVARCHAR(MAX), d.ConnectionCheckQuery), CONVERT(NVARCHAR(MAX),i.ConnectionCheckQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ConnectionCheckQuery <> d.ConnectionCheckQuery OR i.ConnectionCheckQuery IS NULL AND d.ConnectionCheckQuery IS NOT NULL OR i.ConnectionCheckQuery IS NOT NULL AND d.ConnectionCheckQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'ConnectionCheckResult', CONVERT(NVARCHAR(MAX), d.ConnectionCheckResult), CONVERT(NVARCHAR(MAX),i.ConnectionCheckResult),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.ConnectionCheckResult <> d.ConnectionCheckResult OR i.ConnectionCheckResult IS NULL AND d.ConnectionCheckResult IS NOT NULL OR i.ConnectionCheckResult IS NOT NULL AND d.ConnectionCheckResult IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'CheckConnection', CONVERT(NVARCHAR(MAX), d.CheckConnection), CONVERT(NVARCHAR(MAX),i.CheckConnection),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.CheckConnection <> d.CheckConnection OR i.CheckConnection IS NULL AND d.CheckConnection IS NOT NULL OR i.CheckConnection IS NOT NULL AND d.CheckConnection IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'DataCurrencyCheckQuery', CONVERT(NVARCHAR(MAX), d.DataCurrencyCheckQuery), CONVERT(NVARCHAR(MAX),i.DataCurrencyCheckQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.DataCurrencyCheckQuery <> d.DataCurrencyCheckQuery OR i.DataCurrencyCheckQuery IS NULL AND d.DataCurrencyCheckQuery IS NOT NULL OR i.DataCurrencyCheckQuery IS NOT NULL AND d.DataCurrencyCheckQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'DataCurrencyCheckResult', CONVERT(NVARCHAR(MAX), d.DataCurrencyCheckResult), CONVERT(NVARCHAR(MAX),i.DataCurrencyCheckResult),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.DataCurrencyCheckResult <> d.DataCurrencyCheckResult OR i.DataCurrencyCheckResult IS NULL AND d.DataCurrencyCheckResult IS NOT NULL OR i.DataCurrencyCheckResult IS NOT NULL AND d.DataCurrencyCheckResult IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'CheckDataCurrency', CONVERT(NVARCHAR(MAX), d.CheckDataCurrency), CONVERT(NVARCHAR(MAX),i.CheckDataCurrency),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.CheckDataCurrency <> d.CheckDataCurrency OR i.CheckDataCurrency IS NULL AND d.CheckDataCurrency IS NOT NULL OR i.CheckDataCurrency IS NOT NULL AND d.CheckDataCurrency IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'RunAs32bit', CONVERT(NVARCHAR(MAX), d.RunAs32bit), CONVERT(NVARCHAR(MAX),i.RunAs32bit),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.RunAs32bit <> d.RunAs32bit OR i.RunAs32bit IS NULL AND d.RunAs32bit IS NOT NULL OR i.RunAs32bit IS NOT NULL AND d.RunAs32bit IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ExtractControlID,d.ExtractControlID)), 'CheckExtractRowCount', CONVERT(NVARCHAR(MAX), d.CheckExtractRowCount), CONVERT(NVARCHAR(MAX),i.CheckExtractRowCount),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ExtractControlID = d.ExtractControlID
WHERE i.CheckExtractRowCount <> d.CheckExtractRowCount OR i.CheckExtractRowCount IS NULL AND d.CheckExtractRowCount IS NOT NULL OR i.CheckExtractRowCount IS NOT NULL AND d.CheckExtractRowCount IS NULL