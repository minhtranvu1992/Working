

CREATE PROC [Audit].[AuditTriggerGen]
AS
BEGIN
DECLARE @SchemaName NVARCHAR(250)
DECLARE @TableName NVARCHAR(250)
DECLARE @ColumnName NVARCHAR(250)
DECLARE @DataType NVARCHAR(250)
DECLARE	@ColumnNames NVARCHAR(MAX) = ''
DECLARE	@ColumnDeleteNames NVARCHAR(MAX) = ''
DECLARE @PKCols NVARCHAR(MAX) = ''
DECLARE @PKFieldSelect NVARCHAR(MAX) = ''
DECLARE @PKValueSelect NVARCHAR(MAX) = ''
DECLARE @SqlQuery NVARCHAR(MAX) = ''



DECLARE	@ColumnInsertValuesNames NVARCHAR(MAX) = ''
DECLARE	@ColumnDeleteValuesNames NVARCHAR(MAX) = ''

DECLARE	@InsertStatement NVARCHAR(MAX) = ''

SET NOCOUNT ON

IF OBJECT_ID('tempdb..#AuditTables') IS NOT NULL
DROP TABLE #AuditTables

SELECT DISTINCT [SchemaName], [TableName]
INTO #AuditTables
FROM [Audit].[AuditMonitorTableColumns]

WHILE (SELECT COUNT(*) FROM #AuditTables) > 0
BEGIN

	SELECT TOP 1 @SchemaName = SchemaName, @TableName = TableName
	FROM #AuditTables

    SET @ColumnNames = ''
    SET	@ColumnDeleteNames = ''
	SET @ColumnInsertValuesNames = ''
	SET @ColumnDeleteValuesNames = ''
	SET @InsertStatement = ''
	SET @PKCols = ''
	SET @PKFieldSelect = ''
	SET @PKValueSelect = ''
	SET @SqlQuery = ''
	
	IF OBJECT_ID('tempdb..#AuditTableDetails') IS NOT NULL
	DROP TABLE #AuditTableDetails

	SELECT tc.[ColumnName], UPPER(DATA_TYPE) + COALESCE('(' + CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(10) )+ ')', '') AS 'DataType'
	INTO #AuditTableDetails
	FROM [Audit].[AuditMonitorTableColumns] tc
	INNER JOIN INFORMATION_SCHEMA.COLUMNS sc ON sc.COLUMN_NAME = tc.ColumnName AND tc.TableName = sc.TABLE_NAME AND sc.TABLE_SCHEMA = tc.SchemaName
	WHERE TableName = @TableName

	-- Get primary key columns for full outer join
	SELECT  @PKCols = CASE WHEN LEN(@PKCols) = 0
						   THEN COALESCE(@PKCols, ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
						   ELSE COALESCE(@PKCols + ' and', ' on') + ' i.'  + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
					  END
	FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
			INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
	WHERE   pk.TABLE_NAME = @TableName
			AND CONSTRAINT_TYPE = 'PRIMARY KEY'
			AND c.TABLE_NAME = pk.TABLE_NAME
			AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

	-- Get primary key fields select for insert(comma deparated)           
	SELECT  @PKFieldSelect = CASE WHEN LEN(@PKFieldSelect) = 0
								  THEN COALESCE(@PKFieldSelect, '') + COLUMN_NAME
								  ELSE COALESCE(@PKFieldSelect + ' + ', '') + COLUMN_NAME
							 END
	FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
			INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
	WHERE   pk.TABLE_NAME = @TableName
			AND CONSTRAINT_TYPE = 'PRIMARY KEY'
			AND c.TABLE_NAME = pk.TABLE_NAME
			AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

	-- Get primary key values for insert(comma deparated as varchar)           
	SELECT --@PKValueSelect = coalesce(@PKValueSelect+'+','') + 'convert(varchar(100), coalesce(i.' + COLUMN_NAME + ',d.' + COLUMN_NAME + '))' + '+'',''' 
			@PKValueSelect = CASE WHEN LEN(@PKValueSelect) = 0
								  THEN 'convert(varchar(100), coalesce(i.' + COLUMN_NAME + ',d.' + COLUMN_NAME + '))'
								  ELSE COALESCE(@PKValueSelect + ' + '','' + ', '') + 'convert(varchar(100), coalesce(i.' + COLUMN_NAME + ',d.' + COLUMN_NAME + '))'
							 END
	FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
			INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
	WHERE   pk.TABLE_NAME = @TableName
			AND CONSTRAINT_TYPE = 'PRIMARY KEY'
			AND c.TABLE_NAME = pk.TABLE_NAME
			AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME 

	WHILE (SELECT COUNT(*) FROM #AuditTableDetails) > 0
	BEGIN
		SELECT TOP 1 @ColumnName = [ColumnName], @DataType = DataType FROM #AuditTableDetails

		SET @InsertStatement = @InsertStatement + '
INSERT INTO Audit.AuditData (Type, TableName, PrimaryKeyField, PrimaryKeyValue, FieldName, OldValue, NewValue, UpdateDate, UserName)
SELECT @Type, @TableName, @PKFieldSelect, ' + @PKValueSelect +', ''' + @ColumnName + ''', CONVERT(NVARCHAR(MAX), d.' + @ColumnName + '), CONVERT(NVARCHAR(MAX),i.' + @ColumnName + '),@UpdateDate,@UserName
FROM inserted i FULL OUTER JOIN deleted d ON ' + @PKCols + '
WHERE i.' + @ColumnName + ' <> d.' + @ColumnName + ' OR i.' + @ColumnName + ' IS NULL AND d.' + @ColumnName + ' IS NOT NULL OR i.' + @ColumnName + ' IS NOT NULL AND d.' + @ColumnName + ' IS NULL
'




		DELETE FROM #AuditTableDetails WHERE [ColumnName] = @ColumnName
	END
	DELETE FROM #AuditTables WHERE SchemaName = @SchemaName AND TableName = @TableName

SET @SqlQuery = 'SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects o
               INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
			   WHERE  o.[type] = ''TR'' AND  o.[name] = ''' + @TableName + '_ChangeTracking'' AND s.name = ''' + @SchemaName + ''')
  BEGIN 
    EXEC (''CREATE TRIGGER [' + @SchemaName + '].[' + @TableName + '_ChangeTracking] ON [' + @SchemaName + '].[' + @TableName + '] FOR INSERT, UPDATE, DELETE
            AS
            BEGIN
               SELECT 1
            END'')  
  END 
GO  

ALTER TRIGGER [' + @SchemaName + '].[' + @TableName + '_ChangeTracking] on [' + @SchemaName + '].[' + @TableName + '] FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @TableName varchar(128) = ''[' + @SchemaName + '].[' + @TableName + ']''
DECLARE @UpdateDate varchar(21)
DECLARE @UserName varchar(128)
DECLARE @Type char(1)
DECLARE @PKFieldSelect nvarchar(1000) = ''' + @PKFieldSelect + '''
DECLARE @PKValueSelect nvarchar(1000)
 
-- date and user
SELECT @UserName = SYSTEM_USER , @UpdateDate = CONVERT(VARCHAR(8), GETDATE(), 112) + '' '' + CONVERT(VARCHAR(12), GETDATE(), 114)
' + @ColumnNames + '
' + @ColumnDeleteNames + '

-- Action
IF EXISTS (SELECT * FROM inserted)
BEGIN
	--SELECT ' + @ColumnInsertValuesNames + ' FROM inserted
	IF EXISTS (SELECT * FROM deleted)
	BEGIN
	--	SELECT ' + @ColumnDeleteValuesNames + ' FROM deleted
		SELECT @Type = ''U''
	END
	ELSE
	BEGIN
		SELECT @Type = ''I''
	END
END
ELSE
BEGIN
	--SELECT ' + @ColumnDeleteValuesNames + ' FROM deleted
	SELECT @Type = ''D''
END

' + @InsertStatement + '
GO'

EXEC LongPrintN @SqlQuery
END
END