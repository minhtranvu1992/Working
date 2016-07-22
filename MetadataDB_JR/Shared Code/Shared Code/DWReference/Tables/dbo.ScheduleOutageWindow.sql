CREATE TABLE [dbo].[ScheduleOutageWindow] (
    [ScheduleOutageWindowID] INT           IDENTITY (1, 1) NOT NULL,
    [StartDateTime]          DATETIME      NOT NULL,
    [EndDateTime]            DATETIME      NOT NULL,
    [ReasonForOutage]        VARCHAR (400) NULL,
    CONSTRAINT [PK_ScheduleOutageWindow] PRIMARY KEY CLUSTERED ([ScheduleOutageWindowID] ASC)
);




GO

CREATE TRIGGER [dbo].[ScheduleOutageWindow_ChangeTracking] on [dbo].[ScheduleOutageWindow] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[ScheduleOutageWindow]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'ScheduleOutageWindowID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleOutageWindowID,d.ScheduleOutageWindowID)), 'ScheduleOutageWindowID', CONVERT(NVARCHAR(MAX), d.ScheduleOutageWindowID), CONVERT(NVARCHAR(MAX),i.ScheduleOutageWindowID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleOutageWindowID = d.ScheduleOutageWindowID
WHERE i.ScheduleOutageWindowID <> d.ScheduleOutageWindowID OR i.ScheduleOutageWindowID IS NULL AND d.ScheduleOutageWindowID IS NOT NULL OR i.ScheduleOutageWindowID IS NOT NULL AND d.ScheduleOutageWindowID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleOutageWindowID,d.ScheduleOutageWindowID)), 'StartDateTime', CONVERT(NVARCHAR(MAX), d.StartDateTime), CONVERT(NVARCHAR(MAX),i.StartDateTime),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleOutageWindowID = d.ScheduleOutageWindowID
WHERE i.StartDateTime <> d.StartDateTime OR i.StartDateTime IS NULL AND d.StartDateTime IS NOT NULL OR i.StartDateTime IS NOT NULL AND d.StartDateTime IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleOutageWindowID,d.ScheduleOutageWindowID)), 'EndDateTime', CONVERT(NVARCHAR(MAX), d.EndDateTime), CONVERT(NVARCHAR(MAX),i.EndDateTime),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleOutageWindowID = d.ScheduleOutageWindowID
WHERE i.EndDateTime <> d.EndDateTime OR i.EndDateTime IS NULL AND d.EndDateTime IS NOT NULL OR i.EndDateTime IS NOT NULL AND d.EndDateTime IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.ScheduleOutageWindowID,d.ScheduleOutageWindowID)), 'ReasonForOutage', CONVERT(NVARCHAR(MAX), d.ReasonForOutage), CONVERT(NVARCHAR(MAX),i.ReasonForOutage),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.ScheduleOutageWindowID = d.ScheduleOutageWindowID
WHERE i.ReasonForOutage <> d.ReasonForOutage OR i.ReasonForOutage IS NULL AND d.ReasonForOutage IS NOT NULL OR i.ReasonForOutage IS NOT NULL AND d.ReasonForOutage IS NULL