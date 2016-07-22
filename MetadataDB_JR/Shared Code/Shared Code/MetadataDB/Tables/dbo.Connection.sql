CREATE TABLE [dbo].[Connection] (
    [ConnectionID]      VARCHAR (40)  NOT NULL,
    [ConnectionClassID] VARCHAR (40)  NULL,
    [ConnectionName]    VARCHAR (100) NULL,
    [ConnectionString]  VARCHAR (MAX) NULL,
    [SuiteName]         VARCHAR (40)  NULL,
    [SourceName]        VARCHAR (100) NULL,
    [CreatedBy]         VARCHAR (100) CONSTRAINT [DF__Connectio__Creat__7EC1CEDB] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]   DATETIME      CONSTRAINT [DF__Connectio__Creat__7FB5F314] DEFAULT (getdate()) NULL,
    [UpdatedBy]         VARCHAR (100) CONSTRAINT [DF__Connectio__Updat__00AA174D] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]   DATETIME      CONSTRAINT [DF__Connectio__Updat__019E3B86] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CONNECTION] PRIMARY KEY NONCLUSTERED ([ConnectionID] ASC),
    CONSTRAINT [FK_Connection_ConnectionClass] FOREIGN KEY ([ConnectionClassID]) REFERENCES [dbo].[ConnectionClass] ([ConnectionClassID]) ON UPDATE CASCADE
);




























GO
CREATE NONCLUSTERED INDEX [FK_Connection_ConnectionClass]
    ON [dbo].[Connection]([ConnectionClassID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Contains details of the specific connection
For design purposes this should be a DEV or UAT connection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Connection';


GO

GO
CREATE TRIGGER [dbo].[Connection_AfterUpdate]
ON [dbo].[Connection]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Connection
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Connection tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionID = tbl_ins.ConnectionID

	
END
GO


