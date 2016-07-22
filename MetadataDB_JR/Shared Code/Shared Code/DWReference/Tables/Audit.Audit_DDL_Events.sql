CREATE TABLE [Audit].[Audit_DDL_Events] (
    [DDL_Event_Time]    DATETIME       NULL,
    [DDL_Login_Name]    NVARCHAR (150) NULL,
    [DDL_User_Name]     NVARCHAR (150) NULL,
    [DDL_Server_Name]   NVARCHAR (150) NULL,
    [DDL_Database_Name] NVARCHAR (150) NULL,
    [DDL_Schema_Name]   NVARCHAR (150) NULL,
    [DDL_Object_Name]   NVARCHAR (150) NULL,
    [DDL_Object_Type]   NVARCHAR (150) NULL,
    [DDL_Command]       NVARCHAR (MAX) NULL,
    [DDL_CreateCommand] NVARCHAR (MAX) NULL
);

