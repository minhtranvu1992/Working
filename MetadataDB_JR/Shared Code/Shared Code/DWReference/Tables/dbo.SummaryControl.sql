CREATE TABLE [dbo].[SummaryControl] (
    [SummaryControlID]              INT            IDENTITY (1, 1) NOT NULL,
    [SummaryPackageName]            VARCHAR (100)  NOT NULL,
    [SummaryPackagePath]            VARCHAR (100)  NULL,
    [SummaryTableName]              VARCHAR (100)  NULL,
    [ScheduleType]                  VARCHAR (50)   CONSTRAINT [DF_SummaryControl_Suite] DEFAULT ('Daily') NOT NULL,
    [SourceQuery]                   VARCHAR (1000) NULL,
    [Type]                          VARCHAR (50)   NOT NULL,
    [SourceControlID]               INT            NOT NULL,
    [LastSummaryJobID]              INT            NOT NULL,
    [ExecutionOrder]                INT            CONSTRAINT [DF_SummaryControl_ExecutionOrder] DEFAULT ((1)) NOT NULL,
    [LastExecutionTime]             DATETIME       NULL,
    [CurrentDeliveryJobID]          INT            NULL,
    [LastDeliveryJobID]             INT            NULL,
    [ErrorEmailSent]                DATETIME       NULL,
    [MaxExpectedExecutionDuration]  TIME (0)       NULL,
    [MaxExpectedExecutionEmailSent] DATETIME       NULL,
    CONSTRAINT [PK_SummaryControl] PRIMARY KEY CLUSTERED ([SummaryControlID] ASC)
);














GO

CREATE TRIGGER [dbo].[SummaryControl_ChangeTracking] on [dbo].[SummaryControl] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[SummaryControl]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'SummaryControlID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SummaryControlID', CONVERT(NVARCHAR(MAX), d.SummaryControlID), CONVERT(NVARCHAR(MAX),i.SummaryControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SummaryControlID <> d.SummaryControlID OR i.SummaryControlID IS NULL AND d.SummaryControlID IS NOT NULL OR i.SummaryControlID IS NOT NULL AND d.SummaryControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SummaryPackageName', CONVERT(NVARCHAR(MAX), d.SummaryPackageName), CONVERT(NVARCHAR(MAX),i.SummaryPackageName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SummaryPackageName <> d.SummaryPackageName OR i.SummaryPackageName IS NULL AND d.SummaryPackageName IS NOT NULL OR i.SummaryPackageName IS NOT NULL AND d.SummaryPackageName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SummaryPackagePath', CONVERT(NVARCHAR(MAX), d.SummaryPackagePath), CONVERT(NVARCHAR(MAX),i.SummaryPackagePath),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SummaryPackagePath <> d.SummaryPackagePath OR i.SummaryPackagePath IS NULL AND d.SummaryPackagePath IS NOT NULL OR i.SummaryPackagePath IS NOT NULL AND d.SummaryPackagePath IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SummaryTableName', CONVERT(NVARCHAR(MAX), d.SummaryTableName), CONVERT(NVARCHAR(MAX),i.SummaryTableName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SummaryTableName <> d.SummaryTableName OR i.SummaryTableName IS NULL AND d.SummaryTableName IS NOT NULL OR i.SummaryTableName IS NOT NULL AND d.SummaryTableName IS NULL
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'ScheduleType', CONVERT(NVARCHAR(MAX), d.ScheduleType), CONVERT(NVARCHAR(MAX),i.ScheduleType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.ScheduleType <> d.ScheduleType OR i.ScheduleType IS NULL AND d.ScheduleType IS NOT NULL OR i.ScheduleType IS NOT NULL AND d.ScheduleType IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SourceQuery', CONVERT(NVARCHAR(MAX), d.SourceQuery), CONVERT(NVARCHAR(MAX),i.SourceQuery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SourceQuery <> d.SourceQuery OR i.SourceQuery IS NULL AND d.SourceQuery IS NOT NULL OR i.SourceQuery IS NOT NULL AND d.SourceQuery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'Type', CONVERT(NVARCHAR(MAX), d.Type), CONVERT(NVARCHAR(MAX),i.Type),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.Type <> d.Type OR i.Type IS NULL AND d.Type IS NOT NULL OR i.Type IS NOT NULL AND d.Type IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'SourceControlID', CONVERT(NVARCHAR(MAX), d.SourceControlID), CONVERT(NVARCHAR(MAX),i.SourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.SourceControlID <> d.SourceControlID OR i.SourceControlID IS NULL AND d.SourceControlID IS NOT NULL OR i.SourceControlID IS NOT NULL AND d.SourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'ExecutionOrder', CONVERT(NVARCHAR(MAX), d.ExecutionOrder), CONVERT(NVARCHAR(MAX),i.ExecutionOrder),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.ExecutionOrder <> d.ExecutionOrder OR i.ExecutionOrder IS NULL AND d.ExecutionOrder IS NOT NULL OR i.ExecutionOrder IS NOT NULL AND d.ExecutionOrder IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'MaxExpectedExecutionDuration', CONVERT(NVARCHAR(MAX), d.MaxExpectedExecutionDuration), CONVERT(NVARCHAR(MAX),i.MaxExpectedExecutionDuration),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.MaxExpectedExecutionDuration <> d.MaxExpectedExecutionDuration OR i.MaxExpectedExecutionDuration IS NULL AND d.MaxExpectedExecutionDuration IS NOT NULL OR i.MaxExpectedExecutionDuration IS NOT NULL AND d.MaxExpectedExecutionDuration IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SummaryControlID,d.SummaryControlID)), 'MaxExpectedExecutionEmailSent', CONVERT(NVARCHAR(MAX), d.MaxExpectedExecutionEmailSent), CONVERT(NVARCHAR(MAX),i.MaxExpectedExecutionEmailSent),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SummaryControlID = d.SummaryControlID
WHERE i.MaxExpectedExecutionEmailSent <> d.MaxExpectedExecutionEmailSent OR i.MaxExpectedExecutionEmailSent IS NULL AND d.MaxExpectedExecutionEmailSent IS NOT NULL OR i.MaxExpectedExecutionEmailSent IS NOT NULL AND d.MaxExpectedExecutionEmailSent IS NULL