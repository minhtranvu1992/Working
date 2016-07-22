CREATE TABLE [dbo].[ScheduleType] (
    [ScheduleTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [ScheduleTypeName] VARCHAR (100) NULL,
    CONSTRAINT [PK_ScheduleType] PRIMARY KEY CLUSTERED ([ScheduleTypeID] ASC)
);




GO

CREATE TRIGGER [dbo].[ScheduleType_ChangeTracking] on [dbo].[ScheduleType] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[ScheduleType]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'ScheduleTypeID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleTypeID,d.ScheduleTypeID)), 'ScheduleTypeID', CONVERT(NVARCHAR(MAX), d.ScheduleTypeID), CONVERT(NVARCHAR(MAX),i.ScheduleTypeID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleTypeID = d.ScheduleTypeID
WHERE i.ScheduleTypeID <> d.ScheduleTypeID OR i.ScheduleTypeID IS NULL AND d.ScheduleTypeID IS NOT NULL OR i.ScheduleTypeID IS NOT NULL AND d.ScheduleTypeID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleTypeID,d.ScheduleTypeID)), 'ScheduleTypeName', CONVERT(NVARCHAR(MAX), d.ScheduleTypeName), CONVERT(NVARCHAR(MAX),i.ScheduleTypeName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleTypeID = d.ScheduleTypeID
WHERE i.ScheduleTypeName <> d.ScheduleTypeName OR i.ScheduleTypeName IS NULL AND d.ScheduleTypeName IS NOT NULL OR i.ScheduleTypeName IS NOT NULL AND d.ScheduleTypeName IS NULL