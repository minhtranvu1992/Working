		CREATE TRIGGER Audit_DDL 
		ON DATABASE 
		FOR DDL_DATABASE_LEVEL_EVENTS
		AS 
		
			DECLARE @DynamicSQL AS NVARCHAR(MAX);			
			DECLARE @event XML;
			SET @event = EVENTDATA();

			DECLARE	
				@DDL_Event_Time AS DATETIME = REPLACE(CONVERT(NVARCHAR(50), @event.query('data(/EVENT_INSTANCE/PostTime)')), 'T', ' ')
				,@DDL_Login_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/LoginName)'))
				,@DDL_User_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/UserName)'))
				,@DDL_Server_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/ServerName)'))
				,@DDL_Database_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/DatabaseName)'))
				,@DDL_Schema_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/SchemaName)'))
				,@DDL_Object_Name AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/ObjectName)'))
				,@DDL_Object_Type AS NVARCHAR(150) = CONVERT(NVARCHAR(150), @event.query('data(/EVENT_INSTANCE/ObjectType)'))
				,@DDL_Command AS NVARCHAR(max) = CONVERT(NVARCHAR(max), @event.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))
				,@DDL_CreateCommand AS NVARCHAR(max) = ''

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
				);