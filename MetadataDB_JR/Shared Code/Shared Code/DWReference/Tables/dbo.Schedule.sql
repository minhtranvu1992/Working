CREATE TABLE [dbo].[Schedule] (
    [ScheduleID]     INT           IDENTITY (1, 1) NOT NULL,
    [ScheduleName]   VARCHAR (100) NOT NULL,
    [ScheduleTypeID] INT           NOT NULL,
    [StartTime]      TIME (0)      NULL,
    [EndTime]        TIME (0)      NULL,
    [OccursEvery]    TIME (0)      NULL,
    [Mon]            BIT           NULL,
    [Tue]            BIT           NULL,
    [Wed]            BIT           NULL,
    [Thu]            BIT           NULL,
    [Fri]            BIT           NULL,
    [Sat]            BIT           NULL,
    [Sun]            BIT           NULL,
    CONSTRAINT [PK_Schedule] PRIMARY KEY CLUSTERED ([ScheduleID] ASC),
    CONSTRAINT [FK_Schedule_ScheduleType] FOREIGN KEY ([ScheduleTypeID]) REFERENCES [dbo].[ScheduleType] ([ScheduleTypeID]),
    CONSTRAINT [uc_ScheduleScheduleName] UNIQUE NONCLUSTERED ([ScheduleName] ASC)
);






GO

CREATE TRIGGER [dbo].[Schedule_ChangeTracking] on [dbo].[Schedule] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[Schedule]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'ScheduleID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'ScheduleID', CONVERT(NVARCHAR(MAX), d.ScheduleID), CONVERT(NVARCHAR(MAX),i.ScheduleID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.ScheduleID <> d.ScheduleID OR i.ScheduleID IS NULL AND d.ScheduleID IS NOT NULL OR i.ScheduleID IS NOT NULL AND d.ScheduleID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'ScheduleName', CONVERT(NVARCHAR(MAX), d.ScheduleName), CONVERT(NVARCHAR(MAX),i.ScheduleName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.ScheduleName <> d.ScheduleName OR i.ScheduleName IS NULL AND d.ScheduleName IS NOT NULL OR i.ScheduleName IS NOT NULL AND d.ScheduleName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'ScheduleTypeID', CONVERT(NVARCHAR(MAX), d.ScheduleTypeID), CONVERT(NVARCHAR(MAX),i.ScheduleTypeID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.ScheduleTypeID <> d.ScheduleTypeID OR i.ScheduleTypeID IS NULL AND d.ScheduleTypeID IS NOT NULL OR i.ScheduleTypeID IS NOT NULL AND d.ScheduleTypeID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'StartTime', CONVERT(NVARCHAR(MAX), d.StartTime), CONVERT(NVARCHAR(MAX),i.StartTime),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.StartTime <> d.StartTime OR i.StartTime IS NULL AND d.StartTime IS NOT NULL OR i.StartTime IS NOT NULL AND d.StartTime IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'EndTime', CONVERT(NVARCHAR(MAX), d.EndTime), CONVERT(NVARCHAR(MAX),i.EndTime),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.EndTime <> d.EndTime OR i.EndTime IS NULL AND d.EndTime IS NOT NULL OR i.EndTime IS NOT NULL AND d.EndTime IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'OccursEvery', CONVERT(NVARCHAR(MAX), d.OccursEvery), CONVERT(NVARCHAR(MAX),i.OccursEvery),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.OccursEvery <> d.OccursEvery OR i.OccursEvery IS NULL AND d.OccursEvery IS NOT NULL OR i.OccursEvery IS NOT NULL AND d.OccursEvery IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Mon', CONVERT(NVARCHAR(MAX), d.Mon), CONVERT(NVARCHAR(MAX),i.Mon),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Mon <> d.Mon OR i.Mon IS NULL AND d.Mon IS NOT NULL OR i.Mon IS NOT NULL AND d.Mon IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Tue', CONVERT(NVARCHAR(MAX), d.Tue), CONVERT(NVARCHAR(MAX),i.Tue),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Tue <> d.Tue OR i.Tue IS NULL AND d.Tue IS NOT NULL OR i.Tue IS NOT NULL AND d.Tue IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Wed', CONVERT(NVARCHAR(MAX), d.Wed), CONVERT(NVARCHAR(MAX),i.Wed),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Wed <> d.Wed OR i.Wed IS NULL AND d.Wed IS NOT NULL OR i.Wed IS NOT NULL AND d.Wed IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Thu', CONVERT(NVARCHAR(MAX), d.Thu), CONVERT(NVARCHAR(MAX),i.Thu),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Thu <> d.Thu OR i.Thu IS NULL AND d.Thu IS NOT NULL OR i.Thu IS NOT NULL AND d.Thu IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Fri', CONVERT(NVARCHAR(MAX), d.Fri), CONVERT(NVARCHAR(MAX),i.Fri),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Fri <> d.Fri OR i.Fri IS NULL AND d.Fri IS NOT NULL OR i.Fri IS NOT NULL AND d.Fri IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Sat', CONVERT(NVARCHAR(MAX), d.Sat), CONVERT(NVARCHAR(MAX),i.Sat),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Sat <> d.Sat OR i.Sat IS NULL AND d.Sat IS NOT NULL OR i.Sat IS NOT NULL AND d.Sat IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleID,d.ScheduleID)), 'Sun', CONVERT(NVARCHAR(MAX), d.Sun), CONVERT(NVARCHAR(MAX),i.Sun),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleID = d.ScheduleID
WHERE i.Sun <> d.Sun OR i.Sun IS NULL AND d.Sun IS NOT NULL OR i.Sun IS NOT NULL AND d.Sun IS NULL