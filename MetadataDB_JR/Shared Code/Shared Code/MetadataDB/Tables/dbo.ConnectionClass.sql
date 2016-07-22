CREATE TABLE [dbo].[ConnectionClass] (
    [ConnectionClassID]         VARCHAR (40)  NOT NULL,
    [ConnectionClassCategoryID] VARCHAR (40)  NULL,
    [ConnectionClassName]       VARCHAR (100) NULL,
    [CreatedBy]                 VARCHAR (100) CONSTRAINT [DF__Connectio__Creat__02925FBF] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]           DATETIME      CONSTRAINT [DF__Connectio__Creat__038683F8] DEFAULT (getdate()) NULL,
    [UpdatedBy]                 VARCHAR (100) CONSTRAINT [DF__Connectio__Updat__047AA831] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]           DATETIME      CONSTRAINT [DF__Connectio__Updat__056ECC6A] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CONNECTIONCLASS] PRIMARY KEY NONCLUSTERED ([ConnectionClassID] ASC),
    CONSTRAINT [FK_ConnectionClass_ConnectionClassCategory] FOREIGN KEY ([ConnectionClassCategoryID]) REFERENCES [dbo].[ConnectionClassCategory] ([ConnectionClassCategoryID]) ON UPDATE CASCADE
);






















GO
CREATE NONCLUSTERED INDEX [FK_ConnectionClass_ConnectionClassCategory]
    ON [dbo].[ConnectionClass]([ConnectionClassCategoryID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Classifies the connections as to which system type they refer to
e.g. Solomon, AX2009, AX2012, Index Flat files, Data warehouse database', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConnectionClass';


GO

GO
CREATE TRIGGER [dbo].[ConnectionClass_AfterUpdate]
ON [dbo].[ConnectionClass]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ConnectionClass
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClass tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionClassID = tbl_ins.ConnectionClassID

	
END
GO



GO



GO



GO



GO


