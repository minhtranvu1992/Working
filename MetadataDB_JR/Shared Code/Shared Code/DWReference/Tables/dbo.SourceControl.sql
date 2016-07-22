CREATE TABLE [dbo].[SourceControl] (
    [SourceControlID]       INT          IDENTITY (1, 1) NOT NULL,
    [SourceName]            VARCHAR (50) NULL,
    [SourceTypeID]          INT          NULL,
    [AccessWindowStartMins] INT          NULL,
    [AccessWindowEndMins]   INT          NULL,
    [SSISConfigurationID]   INT          NULL,
    CONSTRAINT [PK_SourceControl] PRIMARY KEY CLUSTERED ([SourceControlID] ASC),
    CONSTRAINT [FK_SourceControl_SourceType] FOREIGN KEY ([SourceTypeID]) REFERENCES [dbo].[SourceType] ([SourceTypeID]),
    CONSTRAINT [FK_SourceControl_SSISConfiguration] FOREIGN KEY ([SSISConfigurationID]) REFERENCES [dbo].[SSISConfiguration] ([SSISConfigurationID])
);




GO

CREATE TRIGGER [dbo].[SourceControl_ChangeTracking] on [dbo].[SourceControl] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[SourceControl]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'SourceControlID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'SourceControlID', CONVERT(NVARCHAR(MAX), d.SourceControlID), CONVERT(NVARCHAR(MAX),i.SourceControlID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.SourceControlID <> d.SourceControlID OR i.SourceControlID IS NULL AND d.SourceControlID IS NOT NULL OR i.SourceControlID IS NOT NULL AND d.SourceControlID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'SourceName', CONVERT(NVARCHAR(MAX), d.SourceName), CONVERT(NVARCHAR(MAX),i.SourceName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.SourceName <> d.SourceName OR i.SourceName IS NULL AND d.SourceName IS NOT NULL OR i.SourceName IS NOT NULL AND d.SourceName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'SourceTypeID', CONVERT(NVARCHAR(MAX), d.SourceTypeID), CONVERT(NVARCHAR(MAX),i.SourceTypeID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.SourceTypeID <> d.SourceTypeID OR i.SourceTypeID IS NULL AND d.SourceTypeID IS NOT NULL OR i.SourceTypeID IS NOT NULL AND d.SourceTypeID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'AccessWindowStartMins', CONVERT(NVARCHAR(MAX), d.AccessWindowStartMins), CONVERT(NVARCHAR(MAX),i.AccessWindowStartMins),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.AccessWindowStartMins <> d.AccessWindowStartMins OR i.AccessWindowStartMins IS NULL AND d.AccessWindowStartMins IS NOT NULL OR i.AccessWindowStartMins IS NOT NULL AND d.AccessWindowStartMins IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'AccessWindowEndMins', CONVERT(NVARCHAR(MAX), d.AccessWindowEndMins), CONVERT(NVARCHAR(MAX),i.AccessWindowEndMins),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.AccessWindowEndMins <> d.AccessWindowEndMins OR i.AccessWindowEndMins IS NULL AND d.AccessWindowEndMins IS NOT NULL OR i.AccessWindowEndMins IS NOT NULL AND d.AccessWindowEndMins IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceControlID,d.SourceControlID)), 'SSISConfigurationID', CONVERT(NVARCHAR(MAX), d.SSISConfigurationID), CONVERT(NVARCHAR(MAX),i.SSISConfigurationID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceControlID = d.SourceControlID
WHERE i.SSISConfigurationID <> d.SSISConfigurationID OR i.SSISConfigurationID IS NULL AND d.SSISConfigurationID IS NOT NULL OR i.SSISConfigurationID IS NOT NULL AND d.SSISConfigurationID IS NULL