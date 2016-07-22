SET NOCOUNT ON

/* drop the temporary table if exists */
IF OBJECT_ID('tempdb..#Databases') IS NOT NULL
	DROP TABLE #Databases

SELECT name AS DBName
INTO #Databases
FROM sys.databases
WHERE name in ('Steve_Test', 'DWData', 'DWExtract', 'MetadataDB_NEW', 'DWReference')

DECLARE @DBName AS VARCHAR(100)
DECLARE @SQL AS VARCHAR(MAX)

WHILE (SELECT COUNT(*) FROM #Databases) > 0
BEGIN
	SELECT TOP 1 @DBName = DBName FROM #Databases

	SELECT @SQL = '
USE ' + @DBName + '

GO

	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''Audit'')
	EXEC sys.sp_executesql N''CREATE SCHEMA [Audit]''

	GO



	IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Audit].[Audit_DDL_Events]'') AND type in (N''U''))
	BEGIN
		PRINT N''Create Table Audit_DDL_Events...''
		CREATE TABLE Audit.Audit_DDL_Events (
			DDL_Event_Time DATETIME
			,DDL_Login_Name NVARCHAR(150)
			,DDL_User_Name NVARCHAR(150)
			,DDL_Server_Name NVARCHAR(150)
			,DDL_Database_Name NVARCHAR(150)
			,DDL_Schema_Name NVARCHAR(150)
			,DDL_Object_Name NVARCHAR(150)
			,DDL_Object_Type NVARCHAR(150)
			,DDL_Command NVARCHAR(max)
			,DDL_CreateCommand NVARCHAR(max)
			);
	END
	GO


	DECLARE @SQL AS NVARCHAR(MAX) = ''		CREATE TRIGGER Audit_DDL 
		ON DATABASE 
		FOR DDL_DATABASE_LEVEL_EVENTS
		AS 
		
			DECLARE @DynamicSQL AS NVARCHAR(MAX);			
			DECLARE @event XML;
			SET @event = EVENTDATA();

			DECLARE	
				@DDL_Event_Time AS DATETIME = REPLACE(CONVERT(NVARCHAR(50), @event.query(''''data(/EVENT_INSTANCE/PostTime)'''')), ''''T'''', '''' '''')
				,@DDL_Login_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/LoginName)''''))
				,@DDL_User_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/UserName)''''))
				,@DDL_Server_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/ServerName)''''))
				,@DDL_Database_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/DatabaseName)''''))
				,@DDL_Schema_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/SchemaName)''''))
				,@DDL_Object_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/ObjectName)''''))
				,@DDL_Object_Type AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query(''''data(/EVENT_INSTANCE/ObjectType)''''))
				,@DDL_Command AS NVARCHAR(max) = CONVERT(NVARCHAR(max), @event.query(''''data(/EVENT_INSTANCE/TSQLCommand/CommandText)''''))
				,@DDL_CreateCommand AS NVARCHAR(max) = ''''''''

			INSERT INTO Audit.Audit_DDL_Events
			VALUES (
				@DDL_Event_Time
				,@DDL_Login_Name
				,@DDL_User_Name
				,@DDL_Server_Name
				,@DDL_Database_Name
				,@DDL_Schema_Name
				,@DDL_Object_Name
				,@DDL_Object_Type
				,@DDL_Command
				,@DDL_CreateCommand
				);''


	IF NOT EXISTS (SELECT * FROM sys.triggers
		WHERE name = ''Audit_DDL'')
	BEGIN
		PRINT N''Create Trigger Audit_DDL...''
		exec(@SQL)
	END
	GO
	
	'
	exec [dbo].[udpLongPrint] @SQL

	DELETE FROM #Databases WHERE DBName = @DBName
END







