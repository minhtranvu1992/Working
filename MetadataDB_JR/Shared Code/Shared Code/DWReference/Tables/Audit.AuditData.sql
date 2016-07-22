CREATE TABLE [Audit].[AuditData] (
    [AuditDataID]     INT            IDENTITY (1, 1) NOT NULL,
    [Type]            CHAR (1)       NULL,
    [TableName]       VARCHAR (128)  NULL,
    [PrimaryKeyField] VARCHAR (1000) NULL,
    [PrimaryKeyValue] VARCHAR (1000) NULL,
    [FieldName]       VARCHAR (128)  NULL,
    [OldValue]        NVARCHAR (MAX) NULL,
    [NewValue]        NVARCHAR (MAX) NULL,
    [UpdateDate]      DATETIME       CONSTRAINT [DF__AuditData__Updat__4BCC3ABA] DEFAULT (getdate()) NULL,
    [UserName]        VARCHAR (128)  NULL
);



