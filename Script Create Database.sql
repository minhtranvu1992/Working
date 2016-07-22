DECLARE @SQLCreateDatabases AS VARCHAR(MAX)
SELECT @SQLCreateDatabases = ''


CREATE DATABASE ' + @DWData_ModelDB + '
ON 
( NAME = ' + @DWData_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWData_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWData_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWData_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWData_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWData_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWData_ModelDB + '] SET RECOVERY SIMPLE 



CREATE DATABASE ' + @DWExtract_ModelDB + '
ON 
( NAME = ' + @DWExtract_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWExtract_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWExtract_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWExtract_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWExtract_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWExtract_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWExtract_ModelDB + '] SET RECOVERY SIMPLE 



CREATE DATABASE ' + @DWStaging_ModelDB + '
ON 
( NAME = ' + @DWStaging_ModelDB + ''' + @Default_Data_LExt + ''' +',
    FILENAME = '''''' + @Default_Data_Path + ''' + @DWStaging_ModelDB + ''' + @Default_Data_PExt + '''''',
    SIZE = ' + @DWStaging_Size_DataFile + ',
    FILEGROWTH = 10% )
LOG ON
( NAME = ' + @DWStaging_ModelDB + ''' + @Default_Log_LExt + ''' +',
    FILENAME = '''''' + @Default_Log_Path + ''' + @DWStaging_ModelDB + ''' + @Default_Log_PExt + '''''',
    SIZE = ' + @DWStaging_Size_LogFile + ',
    FILEGROWTH = 10% ) ;


ALTER DATABASE [' + @DWStaging_ModelDB + '] SET RECOVERY SIMPLE 

''

exec (@SQLCreateDatabases)
GO