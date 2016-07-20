--This section is used to get the correct logical and physcial file extensions for the CREATE database statements
	IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = ''zzDefaultPathDB'')   

	BEGIN  
		DROP DATABASE zzDefaultPathDB
	END

	CREATE DATABASE zzDefaultPathDB;

	DECLARE @Data_Path VARCHAR(MAX), 
			@Log_Path VARCHAR(MAX),
			@Default_Data_Path VARCHAR(MAX) = '''',   
			@Default_Log_Path VARCHAR(MAX) = '''',
			@Default_Data_PExt VARCHAR(MAX) = '''',   
			@Default_Data_LExt VARCHAR(MAX) = '''',   
			@Default_Log_PExt VARCHAR(MAX) = '''',
			@Default_Log_LExt VARCHAR(MAX) = '''';


		SELECT 
			@Data_Path =  RTRIM(physical_name),
			@Default_Data_Path =  RTRIM((LEFT(physical_name,LEN(physical_name)-CHARINDEX(''\'',REVERSE(physical_name))+1))), 
			@Default_Data_LExt = RTRIM(REPLACE(mf.name, ''zzDefaultPathDB'', ''''))
		FROM sys.master_files mf   
			INNER JOIN sys.[databases] d   
			ON mf.[database_id] = d.[database_id]   
		WHERE d.[name] = ''zzDefaultPathDB'' AND type = 0;

		SELECT 
			@Log_Path =  RTRIM(physical_name),
			@Default_Log_Path =  RTRIM((LEFT(physical_name,LEN(physical_name)-CHARINDEX(''\'',REVERSE(physical_name))+1))), 
			@Default_Log_LExt = RTRIM(REPLACE(mf.name, ''zzDefaultPathDB'', ''''))
		FROM sys.master_files mf   
		INNER JOIN sys.[databases] d   
		ON mf.[database_id] = d.[database_id]   
		WHERE d.[name] = ''zzDefaultPathDB'' AND type = 1;

	--Clean up. Drop de temp database 
	IF EXISTS(SELECT 1 FROM [master].[sys].[databases] WHERE [name] = ''zzDefaultPathDB'')   
	BEGIN  
		DROP DATABASE zzDefaultPathDB   
	END;

	SELECT @Default_Data_PExt = REPLACE(REPLACE(@Data_Path, @Default_Data_Path, ''''), ''zzDefaultPathDB'', '''')
	SELECT @Default_Log_PExt = REPLACE(REPLACE(@Log_Path, @Default_Log_Path, ''''), ''zzDefaultPathDB'', '''')
--End of Section for Database Sizing
