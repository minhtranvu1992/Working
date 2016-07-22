
CREATE TRIGGER [Audit].[AuditMonitorTableColumns_ChangeTracking] on [Audit].[AuditMonitorTableColumns] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[Audit].[AuditMonitorTableColumns]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'AuditMonitorTableColumnsID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AuditMonitorTableColumnsID,d.AuditMonitorTableColumnsID)), 'AuditMonitorTableColumnsID', CONVERT(NVARCHAR(MAX), d.AuditMonitorTableColumnsID), CONVERT(NVARCHAR(MAX),i.AuditMonitorTableColumnsID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AuditMonitorTableColumnsID = d.AuditMonitorTableColumnsID
WHERE i.AuditMonitorTableColumnsID <> d.AuditMonitorTableColumnsID OR i.AuditMonitorTableColumnsID IS NULL AND d.AuditMonitorTableColumnsID IS NOT NULL OR i.AuditMonitorTableColumnsID IS NOT NULL AND d.AuditMonitorTableColumnsID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.AuditMonitorTableColumnsID,d.AuditMonitorTableColumnsID)), 'TableName', CONVERT(NVARCHAR(MAX), d.TableName), CONVERT(NVARCHAR(MAX),i.TableName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.AuditMonitorTableColumnsID = d.AuditMonitorTableColumnsID
WHERE i.TableName <> d.TableName OR i.TableName IS NULL AND d.TableName IS NOT NULL OR i.TableName IS NOT NULL AND d.TableName IS NULL