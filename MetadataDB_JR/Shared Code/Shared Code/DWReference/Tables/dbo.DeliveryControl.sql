CREATE TABLE [dbo].[DeliveryControl] (
    [DeliveryControlID]             INT           IDENTITY (1, 1) NOT NULL,
    [DeliveryPackageName]           VARCHAR (100) NOT NULL,
    [DeliveryPackagePath]           VARCHAR (100) NULL,
    [ProcessType]                   VARCHAR (100) NULL,
    [DeliveryTable]                 VARCHAR (100) NULL,
    [SourceControlID]               INT           NULL,
    [ExtractTable]                  VARCHAR (100) NULL,
    [ErrorTable]                    VARCHAR (100) NULL,
    [ScheduleType]                  VARCHAR (100) NULL,
    [SourceIdentifier]              VARCHAR (100) NULL,
    [BusinessKeyFieldList]          VARCHAR (500) NULL,
    [ExecutionOrder]                INT           NOT NULL,
    [LastExecutionTime]             DATETIME      CONSTRAINT [DF_DeliveryControl_LastExecutionTime1] DEFAULT ('1900-01-01 00:00:00') NOT NULL,
    [LastDeliveryJobID]             INT           CONSTRAINT [DF_DeliveryControl_LastDeliveryJobID1] DEFAULT ((0)) NOT NULL,
    [LastExtractJobID]              INT           NULL,
    [CurrentExtractJobID]           INT           NULL,
    [ErrorRaised]                   DATETIME      NULL,
    [ErrorEmailSent]                DATETIME      NULL,
    [MaxExpectedExecutionDuration]  TIME (0)      NULL,
    [MaxExpectedExecutionEmailSent] DATETIME      NULL,
    [InsertOnly]                    BIT           NULL,
    CONSTRAINT [PK_DeliveryControl] PRIMARY KEY CLUSTERED ([DeliveryControlID] ASC)
);










GO

CREATE TRIGGER [dbo].[DeliveryControl_ChangeTracking] on [dbo].[DeliveryControl] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[DeliveryControl]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'DeliveryControlID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'DeliveryControlID', CONVERT(NVARCHAR(MAX), d.DeliveryControlID), CONVERT(NVARCHAR(MAX),i.DeliveryControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.DeliveryControlID <> d.DeliveryControlID OR i.DeliveryControlID IS NULL AND d.DeliveryControlID IS NOT NULL OR i.DeliveryControlID IS NOT NULL AND d.DeliveryControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'DeliveryPackageName', CONVERT(NVARCHAR(MAX), d.DeliveryPackageName), CONVERT(NVARCHAR(MAX),i.DeliveryPackageName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.DeliveryPackageName <> d.DeliveryPackageName OR i.DeliveryPackageName IS NULL AND d.DeliveryPackageName IS NOT NULL OR i.DeliveryPackageName IS NOT NULL AND d.DeliveryPackageName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'DeliveryPackagePath', CONVERT(NVARCHAR(MAX), d.DeliveryPackagePath), CONVERT(NVARCHAR(MAX),i.DeliveryPackagePath),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.DeliveryPackagePath <> d.DeliveryPackagePath OR i.DeliveryPackagePath IS NULL AND d.DeliveryPackagePath IS NOT NULL OR i.DeliveryPackagePath IS NOT NULL AND d.DeliveryPackagePath IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'ProcessType', CONVERT(NVARCHAR(MAX), d.ProcessType), CONVERT(NVARCHAR(MAX),i.ProcessType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.ProcessType <> d.ProcessType OR i.ProcessType IS NULL AND d.ProcessType IS NOT NULL OR i.ProcessType IS NOT NULL AND d.ProcessType IS NULL
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'DeliveryTable', CONVERT(NVARCHAR(MAX), d.DeliveryTable), CONVERT(NVARCHAR(MAX),i.DeliveryTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.DeliveryTable <> d.DeliveryTable OR i.DeliveryTable IS NULL AND d.DeliveryTable IS NOT NULL OR i.DeliveryTable IS NOT NULL AND d.DeliveryTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'SourceControlID', CONVERT(NVARCHAR(MAX), d.SourceControlID), CONVERT(NVARCHAR(MAX),i.SourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.SourceControlID <> d.SourceControlID OR i.SourceControlID IS NULL AND d.SourceControlID IS NOT NULL OR i.SourceControlID IS NOT NULL AND d.SourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'ExtractTable', CONVERT(NVARCHAR(MAX), d.ExtractTable), CONVERT(NVARCHAR(MAX),i.ExtractTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.ExtractTable <> d.ExtractTable OR i.ExtractTable IS NULL AND d.ExtractTable IS NOT NULL OR i.ExtractTable IS NOT NULL AND d.ExtractTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'ErrorTable', CONVERT(NVARCHAR(MAX), d.ErrorTable), CONVERT(NVARCHAR(MAX),i.ErrorTable),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.ErrorTable <> d.ErrorTable OR i.ErrorTable IS NULL AND d.ErrorTable IS NOT NULL OR i.ErrorTable IS NOT NULL AND d.ErrorTable IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'ScheduleType', CONVERT(NVARCHAR(MAX), d.ScheduleType), CONVERT(NVARCHAR(MAX),i.ScheduleType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.ScheduleType <> d.ScheduleType OR i.ScheduleType IS NULL AND d.ScheduleType IS NOT NULL OR i.ScheduleType IS NOT NULL AND d.ScheduleType IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'SourceIdentifier', CONVERT(NVARCHAR(MAX), d.SourceIdentifier), CONVERT(NVARCHAR(MAX),i.SourceIdentifier),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.SourceIdentifier <> d.SourceIdentifier OR i.SourceIdentifier IS NULL AND d.SourceIdentifier IS NOT NULL OR i.SourceIdentifier IS NOT NULL AND d.SourceIdentifier IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'BusinessKeyFieldList', CONVERT(NVARCHAR(MAX), d.BusinessKeyFieldList), CONVERT(NVARCHAR(MAX),i.BusinessKeyFieldList),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.BusinessKeyFieldList <> d.BusinessKeyFieldList OR i.BusinessKeyFieldList IS NULL AND d.BusinessKeyFieldList IS NOT NULL OR i.BusinessKeyFieldList IS NOT NULL AND d.BusinessKeyFieldList IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'ExecutionOrder', CONVERT(NVARCHAR(MAX), d.ExecutionOrder), CONVERT(NVARCHAR(MAX),i.ExecutionOrder),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.ExecutionOrder <> d.ExecutionOrder OR i.ExecutionOrder IS NULL AND d.ExecutionOrder IS NOT NULL OR i.ExecutionOrder IS NOT NULL AND d.ExecutionOrder IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'MaxExpectedExecutionDuration', CONVERT(NVARCHAR(MAX), d.MaxExpectedExecutionDuration), CONVERT(NVARCHAR(MAX),i.MaxExpectedExecutionDuration),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.MaxExpectedExecutionDuration <> d.MaxExpectedExecutionDuration OR i.MaxExpectedExecutionDuration IS NULL AND d.MaxExpectedExecutionDuration IS NOT NULL OR i.MaxExpectedExecutionDuration IS NOT NULL AND d.MaxExpectedExecutionDuration IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.DeliveryControlID,d.DeliveryControlID)), 'InsertOnly', CONVERT(NVARCHAR(MAX), d.InsertOnly), CONVERT(NVARCHAR(MAX),i.InsertOnly),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.DeliveryControlID = d.DeliveryControlID
WHERE i.InsertOnly <> d.InsertOnly OR i.InsertOnly IS NULL AND d.InsertOnly IS NOT NULL OR i.InsertOnly IS NOT NULL AND d.InsertOnly IS NULL