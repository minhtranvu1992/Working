--Create Dummy records in DataModel 

--1 List tables in order of generation

--1.1 Get table List
SET NOCOUNT ON 
GO

if object_id ('tempdb..#table_list' ) is not null
    DROP TABLE #table_list


SELECT 
    parent_schema.name AS SchemaName, 
    tables.name AS TableName,
    9999 AS CreateOrder
INTO #table_list
FROM
    sys.Tables tables
    INNER JOIN sys.schemas parent_schema
	   ON tables.schema_id = parent_schema.schema_id
WHERE type_desc = 'USER_TABLE'

--1.2 Get column list
if object_id ('tempdb..#Columns' ) is not null
    DROP TABLE #Columns

SELECT
    parent_schema.name AS SchemaName,
    tables.name AS TableName,
    col.name AS ColumnName,
    typ.name AS DataType,
    pkcols.key_ordinal AS Primarykeyorder,
    col.is_identity AS IsIdentity
INTO #Columns
FROM
    sys.Tables tables
    INNER JOIN sys.schemas parent_schema
	   ON tables.schema_id = parent_schema.schema_id
    INNER JOIN sys.columns col
	   ON tables.object_id = col.object_id
    INNER JOIN sys.types typ
	   ON col.user_type_id = typ.user_type_id
    LEFT JOIN 
    (SELECT 
	   i.object_id,
	   ic.column_id,
	   ic.key_ordinal
    FROM 
	   sys.indexes i
	   LEFT JOIN sys.index_columns ic
		  ON i.object_id = ic.object_id and i.index_id = ic.index_id
	WHERE i.is_primary_key = 1) pkcols
	ON tables.object_id = pkcols.object_id AND col.column_id = pkcols.column_id

if object_id ('tempdb..#table_Process_list' ) is not null
    DROP TABLE #table_Process_list

SELECT tl.*, COALESCE(has_identity_col.HasIdentityCol, 0) AS HasIdentityCol
INTO #table_Process_list
FROM
    #table_list tl
    LEFT JOIN (SELECT DISTINCT TableName, SchemaName, 1 AS HasIdentityCol FROM #Columns WHERE IsIdentity = 1) has_identity_col
    ON tl.SchemaName = has_identity_col.SchemaName AND tl.TableName = has_identity_col.TableName


DECLARE @SchemaName AS VARCHAR(50)
DECLARE @TableName AS VARCHAR(100)
DECLARE @HasIdentityCol AS BIT
DECLARE @ColumnName AS VARCHAR(100)
DECLARE @DataType AS VARCHAR(100)
DECLARE @PrimaryKeyOrder AS INTEGER
DECLARE @SQLComplete AS VARCHAR(MAX) = ''
DECLARE @TableHeader AS VARCHAR(MAX) = ''
DECLARE @TableFooter AS VARCHAR(MAX) = ''
DECLARE @SQLTable AS VARCHAR(MAX)
DECLARE @SQLTableRow AS VARCHAR(MAX) = ''
DECLARE @SQLColumnList AS VARCHAR(MAX) = ''
DECLARE @SQLValuesList AS VARCHAR(MAX) = ''
DECLARE @iRows AS INTEGER = 20
DECLARE @iCounter AS INTEGER = 0
DECLARE @iCounterEven AS INTEGER = 0
DECLARE @cCounter AS VARCHAR(20)
DECLARE @cCounterEven AS VARCHAR(20)

PRINT 'EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"'

WHILE (SELECT COUNT(*) FROM #table_Process_list) > 0
BEGIN
    SELECT TOP 1 
	   @SchemaName = SchemaName,
	   @TableName = TableName,
	   @HasIdentityCol = HasIdentityCol
    FROM #table_Process_list
    ORDER BY SchemaName, TableName

    IF @HasIdentityCol = 1 
    BEGIN
	   SET @TableHeader = 'SET IDENTITY_INSERT ' + @SchemaName + '.' + @TableName + ' ON
'
	   SET @TableFooter = 'SET IDENTITY_INSERT ' + @SchemaName + '.' + @TableName + ' OFF
'
    END

    PRINT @TableHeader

    WHILE (@iCounter < @iRows)
    BEGIN
	   SET @iCounter = @iCounter + 1
	   SET @iCounterEven = CASE WHEN @iCounter = 1 THEN 2 ELSE (round(@iCounter / 2, 0) * 2) END
	   SET @cCounter = CAST(@iCounter AS VARCHAR)
	   SET @cCounterEven = CAST(@iCounterEven AS VARCHAR)

	   if object_id ('tempdb..#col_Process_list' ) is not null
	   DROP TABLE #col_Process_list

	   SELECT * 
	   INTO #col_Process_list
	   FROM #Columns c
	   WHERE c.SchemaName = @SchemaName AND c.TableName = @TableName

	   WHILE (SELECT COUNT(*) FROM #col_Process_list) > 0
	   BEGIN
		  SELECT TOP 1
			 @ColumnName = ColumnName,
			 @DataType = DataType,
			 @PrimaryKeyOrder = COALESCE(PrimaryKeyOrder, 0)
		  FROM #col_Process_list
		  ORDER BY  COALESCE(PrimaryKeyOrder, 999), ColumnName

		  SET @SQLColumnList = @SQLColumnList + @ColumnName + ', '
		  SET @SQLValuesList = @SQLValuesList +
			 (CASE 
				--PrimaryKey
				WHEN @PrimaryKeyOrder > 0 
				    THEN @cCounter
				--ForeignKey
				WHEN @ColumnName LIKE '%SK' AND @DataType LIKE '%int%'
				    THEN @cCounterEven
				--Character Fields
				WHEN @DataType LIKE '%char%'
				    THEN ('''' + @cCounter + '''')
				WHEN @DataType LIKE '%date%'
				    THEN '''1900-01-01'''
				ELSE @cCounter
			 END) + ', '
				


		  DELETE FROM #col_Process_list WHERE  SchemaName = @SchemaName and TableName = @TableName AND ColumnName = @ColumnName
	   END

	   --Remove Last Comma from Lists
	   SET @SQLColumnList = LEFT(@SQLColumnList, LEN(@SQLColumnList) - 1)
	   SET @SQLValuesList = LEFT(@SQLValuesList, LEN(@SQLValuesList) - 1)

	   SET @SQLTableRow = 'INSERT INTO ' + @SchemaName + '.' + @TableName + ' (' + @SQLColumnList + ')
' +				  'VALUES (' + @SQLValuesList + ')
GO
'

	   PRINT @SQLTableRow

	   SET @SQLColumnList = ''
	   SET @SQLValuesList = ''
    END
    
    PRINT @TableFooter

    SET @iCounter = 0
    SET @SQLTableRow = ''
    SET @TableHeader = ''
    SET @TableFooter = ''

    DELETE FROM #table_Process_list WHERE SchemaName = @SchemaName and TableName = @TableName

END

PRINT 'EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"'

	   
	   
SELECT CAST(10 AS VARCHAR)