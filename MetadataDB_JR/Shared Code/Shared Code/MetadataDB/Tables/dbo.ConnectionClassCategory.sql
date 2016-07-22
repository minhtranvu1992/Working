CREATE TABLE [dbo].[ConnectionClassCategory] (
    [ConnectionClassCategoryID]   VARCHAR (40)  NOT NULL,
    [ConnectionClassCategoryName] VARCHAR (100) NULL,
    [SourceType]                  VARCHAR (100) NULL,
    [CreatedBy]                   VARCHAR (100) CONSTRAINT [DF__Connectio__Creat__0662F0A3] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]             DATETIME      CONSTRAINT [DF__Connectio__Creat__075714DC] DEFAULT (getdate()) NULL,
    [UpdatedBy]                   VARCHAR (100) CONSTRAINT [DF__Connectio__Updat__084B3915] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]             DATETIME      CONSTRAINT [DF__Connectio__Updat__093F5D4E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CONNECTIONCLASSCATEGORY] PRIMARY KEY NONCLUSTERED ([ConnectionClassCategoryID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Contains details\ attributes specific to the format of the source (e.g. Flat file, SQL Server, Oracle, etc..)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConnectionClassCategory';


GO

GO
CREATE TRIGGER [dbo].[ConnectionClassCategory_AfterUpdate]
ON [dbo].[ConnectionClassCategory]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ConnectionClassCategory
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClassCategory tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionClassCategoryID = tbl_ins.ConnectionClassCategoryID

	
END
GO



GO



GO



GO



GO


