CREATE TABLE [dbo].[SourceType] (
    [SourceTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [SourceTypeName] VARCHAR (100) NULL,
    CONSTRAINT [PK_SourceType] PRIMARY KEY CLUSTERED ([SourceTypeID] ASC)
);




GO

CREATE TRIGGER [dbo].[SourceType_ChangeTracking] on [dbo].[SourceType] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[SourceType]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'SourceTypeID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceTypeID,d.SourceTypeID)), 'SourceTypeID', CONVERT(NVARCHAR(MAX), d.SourceTypeID), CONVERT(NVARCHAR(MAX),i.SourceTypeID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceTypeID = d.SourceTypeID
WHERE i.SourceTypeID <> d.SourceTypeID OR i.SourceTypeID IS NULL AND d.SourceTypeID IS NOT NULL OR i.SourceTypeID IS NOT NULL AND d.SourceTypeID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SourceTypeID,d.SourceTypeID)), 'SourceTypeName', CONVERT(NVARCHAR(MAX), d.SourceTypeName), CONVERT(NVARCHAR(MAX),i.SourceTypeName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SourceTypeID = d.SourceTypeID
WHERE i.SourceTypeName <> d.SourceTypeName OR i.SourceTypeName IS NULL AND d.SourceTypeName IS NOT NULL OR i.SourceTypeName IS NOT NULL AND d.SourceTypeName IS NULL