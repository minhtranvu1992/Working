CREATE TABLE [dbo].[SSISConfiguration] (
    [SSISConfigurationID] INT            IDENTITY (1, 1) NOT NULL,
    [ConfigurationFilter] NVARCHAR (255) NOT NULL,
    [ConfiguredValue]     NVARCHAR (500) NULL,
    [PackagePath]         NVARCHAR (255) NOT NULL,
    [ConfiguredValueType] NVARCHAR (20)  NOT NULL,
    [Description]         NVARCHAR (255) NULL,
    CONSTRAINT [PK_SSISConfigurationID] PRIMARY KEY CLUSTERED ([SSISConfigurationID] ASC),
    CONSTRAINT [IX_SSISConfiguration_ConfiguratonFilter] UNIQUE NONCLUSTERED ([ConfigurationFilter] ASC)
);






GO

CREATE TRIGGER [dbo].[SSISConfiguration_ChangeTracking] on [dbo].[SSISConfiguration] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[SSISConfiguration]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'SSISConfigurationID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'SSISConfigurationID', CONVERT(NVARCHAR(MAX), d.SSISConfigurationID), CONVERT(NVARCHAR(MAX),i.SSISConfigurationID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.SSISConfigurationID <> d.SSISConfigurationID OR i.SSISConfigurationID IS NULL AND d.SSISConfigurationID IS NOT NULL OR i.SSISConfigurationID IS NOT NULL AND d.SSISConfigurationID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'ConfigurationFilter', CONVERT(NVARCHAR(MAX), d.ConfigurationFilter), CONVERT(NVARCHAR(MAX),i.ConfigurationFilter),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.ConfigurationFilter <> d.ConfigurationFilter OR i.ConfigurationFilter IS NULL AND d.ConfigurationFilter IS NOT NULL OR i.ConfigurationFilter IS NOT NULL AND d.ConfigurationFilter IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'ConfiguredValue', CONVERT(NVARCHAR(MAX), d.ConfiguredValue), CONVERT(NVARCHAR(MAX),i.ConfiguredValue),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.ConfiguredValue <> d.ConfiguredValue OR i.ConfiguredValue IS NULL AND d.ConfiguredValue IS NOT NULL OR i.ConfiguredValue IS NOT NULL AND d.ConfiguredValue IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'PackagePath', CONVERT(NVARCHAR(MAX), d.PackagePath), CONVERT(NVARCHAR(MAX),i.PackagePath),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.PackagePath <> d.PackagePath OR i.PackagePath IS NULL AND d.PackagePath IS NOT NULL OR i.PackagePath IS NOT NULL AND d.PackagePath IS NULL
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'ConfiguredValueType', CONVERT(NVARCHAR(MAX), d.ConfiguredValueType), CONVERT(NVARCHAR(MAX),i.ConfiguredValueType),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.ConfiguredValueType <> d.ConfiguredValueType OR i.ConfiguredValueType IS NULL AND d.ConfiguredValueType IS NOT NULL OR i.ConfiguredValueType IS NOT NULL AND d.ConfiguredValueType IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SSISConfigurationID,d.SSISConfigurationID)), 'Description', CONVERT(NVARCHAR(MAX), d.Description), CONVERT(NVARCHAR(MAX),i.Description),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SSISConfigurationID = d.SSISConfigurationID
WHERE i.Description <> d.Description OR i.Description IS NULL AND d.Description IS NOT NULL OR i.Description IS NOT NULL AND d.Description IS NULL