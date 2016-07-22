CREATE TABLE [dbo].[Suite] (
    [SuiteID]                       INT          IDENTITY (1, 1) NOT NULL,
    [SuiteName]                     VARCHAR (50) NULL,
    [Status]                        CHAR (1)     NULL,
    [StatusChangeDateTime]          DATETIME     NULL,
    [MaxExpectedExecutionDuration]  TIME (0)     NULL,
    [MaxExpectedExecutionEmailSent] DATETIME     NULL,
    CONSTRAINT [PK_Suite] PRIMARY KEY CLUSTERED ([SuiteID] ASC)
);




GO

CREATE TRIGGER [dbo].[Suite_ChangeTracking] on [dbo].[Suite] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = '[dbo].[Suite]'
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = 'SuiteID'
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
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SuiteID,d.SuiteID)), 'SuiteID', CONVERT(NVARCHAR(MAX), d.SuiteID), CONVERT(NVARCHAR(MAX),i.SuiteID),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SuiteID = d.SuiteID
WHERE i.SuiteID <> d.SuiteID OR i.SuiteID IS NULL AND d.SuiteID IS NOT NULL OR i.SuiteID IS NOT NULL AND d.SuiteID IS NULL

INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, convert(varchar(100), coalesce(i.SuiteID,d.SuiteID)), 'SuiteName', CONVERT(NVARCHAR(MAX), d.SuiteName), CONVERT(NVARCHAR(MAX),i.SuiteName),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON  i.SuiteID = d.SuiteID
WHERE i.SuiteName <> d.SuiteName OR i.SuiteName IS NULL AND d.SuiteName IS NOT NULL OR i.SuiteName IS NOT NULL AND d.SuiteName IS NULL