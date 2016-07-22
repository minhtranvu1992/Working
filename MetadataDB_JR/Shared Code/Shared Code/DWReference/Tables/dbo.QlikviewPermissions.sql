CREATE TABLE [dbo].[QlikviewPermissions] (
    [PermissionType]        VARCHAR (50)  NOT NULL,
    [AccountName]           VARCHAR (255) NOT NULL,
    [Permission]            VARCHAR (255) NOT NULL,
    [PermissionDescription] VARCHAR (255) NULL,
    [LastChangeDateTime]    DATETIME      NULL,
    [LastChangedBy]         VARCHAR (255) NULL,
    CONSTRAINT [PK_QlikviewPermissions] PRIMARY KEY CLUSTERED ([PermissionType] ASC, [AccountName] ASC, [Permission] ASC)
);



GO


CREATE TRIGGER [dbo].QlikviewPermissionsChangeTrigger 
ON [dbo].QlikviewPermissions
AFTER INSERT, UPDATE AS
	UPDATE QlikviewPermissions
	SET [LastChangeDateTime] = GETDATE()
		,[LastChangedBy] = System_User
	WHERE exists (select * 
				from inserted
				where QlikviewPermissions.PermissionType = inserted.PermissionType 
				and QlikviewPermissions.AccountName = inserted.AccountName 
				and QlikviewPermissions.Permission = inserted.Permission)

GO

CREATE TRIGGER [dbo].[QlikviewPermissions_ChangeTracking] on [dbo].[QlikviewPermissions] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[QlikviewPermissions]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'AccountName + Permission + PermissionType'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AccountName,d.AccountName)) + ',' + convert(varchar(100), coalesce(i.Permission,d.Permission)) + ',' + convert(varchar(100), coalesce(i.PermissionType,d.PermissionType)), 'PermissionType', CONVERT(NVARCHAR(MAX), d.PermissionType), CONVERT(NVARCHAR(MAX),i.PermissionType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AccountName = d.AccountName and i.Permission = d.Permission and i.PermissionType = d.PermissionType
WHERE i.PermissionType <> d.PermissionType OR i.PermissionType IS NULL AND d.PermissionType IS NOT NULL OR i.PermissionType IS NOT NULL AND d.PermissionType IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AccountName,d.AccountName)) + ',' + convert(varchar(100), coalesce(i.Permission,d.Permission)) + ',' + convert(varchar(100), coalesce(i.PermissionType,d.PermissionType)), 'AccountName', CONVERT(NVARCHAR(MAX), d.AccountName), CONVERT(NVARCHAR(MAX),i.AccountName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AccountName = d.AccountName and i.Permission = d.Permission and i.PermissionType = d.PermissionType
WHERE i.AccountName <> d.AccountName OR i.AccountName IS NULL AND d.AccountName IS NOT NULL OR i.AccountName IS NOT NULL AND d.AccountName IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AccountName,d.AccountName)) + ',' + convert(varchar(100), coalesce(i.Permission,d.Permission)) + ',' + convert(varchar(100), coalesce(i.PermissionType,d.PermissionType)), 'Permission', CONVERT(NVARCHAR(MAX), d.Permission), CONVERT(NVARCHAR(MAX),i.Permission),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AccountName = d.AccountName and i.Permission = d.Permission and i.PermissionType = d.PermissionType
WHERE i.Permission <> d.Permission OR i.Permission IS NULL AND d.Permission IS NOT NULL OR i.Permission IS NOT NULL AND d.Permission IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AccountName,d.AccountName)) + ',' + convert(varchar(100), coalesce(i.Permission,d.Permission)) + ',' + convert(varchar(100), coalesce(i.PermissionType,d.PermissionType)), 'PermissionDescription', CONVERT(NVARCHAR(MAX), d.PermissionDescription), CONVERT(NVARCHAR(MAX),i.PermissionDescription),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AccountName = d.AccountName and i.Permission = d.Permission and i.PermissionType = d.PermissionType
WHERE i.PermissionDescription <> d.PermissionDescription OR i.PermissionDescription IS NULL AND d.PermissionDescription IS NOT NULL OR i.PermissionDescription IS NOT NULL AND d.PermissionDescription IS NULL