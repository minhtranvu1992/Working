CREATE TABLE [Audit].[AuditMonitorTableColumns] (
    [AuditMonitorTableColumnsID] INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]                 NVARCHAR (250) NULL,
    [TableName]                  NVARCHAR (250) NULL,
    [ColumnName]                 NVARCHAR (250) NULL,
    CONSTRAINT [PK_AuditMonitorTableColumns] PRIMARY KEY CLUSTERED ([AuditMonitorTableColumnsID] ASC)
);



