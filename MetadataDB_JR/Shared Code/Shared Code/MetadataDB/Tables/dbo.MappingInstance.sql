CREATE TABLE [dbo].[MappingInstance] (
    [MappingInstanceID]   VARCHAR (40)   NOT NULL,
    [MappingSetID]        VARCHAR (40)   NULL,
    [MappingInstanceDesc] VARCHAR (4000) NOT NULL,
    [SourceConnectionID]  VARCHAR (40)   NULL,
    [IncludeInBuild]      BIT            NULL,
    [CreatedBy]           VARCHAR (100)  CONSTRAINT [DF__MappingIn__Creat__436BFEE3] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME       CONSTRAINT [DF__MappingIn__Creat__4460231C] DEFAULT (getdate()) NULL,
    [UpdatedBy]           VARCHAR (100)  CONSTRAINT [DF__MappingIn__Updat__45544755] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME       CONSTRAINT [DF__MappingIn__Updat__46486B8E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MAPPINGINSTANCE] PRIMARY KEY NONCLUSTERED ([MappingInstanceID] ASC),
    CONSTRAINT [FK_MappingInstance_MappingSet] FOREIGN KEY ([MappingSetID]) REFERENCES [dbo].[MappingSet] ([MappingSetID]) ON UPDATE CASCADE
);
























GO
CREATE NONCLUSTERED INDEX [FK_MappingInstance_MappingSet]
    ON [dbo].[MappingInstance]([MappingSetID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Details an instance of a mapping Set
(e.g. the standard solomon mapping set has been defined, and it is being implement in the following Mapping Instances.. e.g. BOSS, HK, Malaysia)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MappingInstance';


GO

GO
CREATE TRIGGER [dbo].[MappingInstance_AfterUpdate]
ON [dbo].[MappingInstance]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingInstance
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingInstance tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingInstanceID = tbl_ins.MappingInstanceID

	
END
GO



GO



GO



GO



GO


