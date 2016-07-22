CREATE TABLE [dbo].[MappingSetMapping] (
    [MappingSetID]    VARCHAR (40)  NOT NULL,
    [MappingID]       VARCHAR (100) NOT NULL,
    [BuildOrder]      INT           NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__MappingSe__Creat__4B0D20AB] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__MappingSe__Creat__4C0144E4] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__MappingSe__Updat__4CF5691D] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__MappingSe__Updat__4DE98D56] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MAPPINGSETMAPPING] PRIMARY KEY NONCLUSTERED ([MappingSetID] ASC, [MappingID] ASC),
    CONSTRAINT [FK_MappingSetMapping_Mapping] FOREIGN KEY ([MappingID]) REFERENCES [dbo].[Mapping] ([MappingID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_MappingSetMapping_MappingSet] FOREIGN KEY ([MappingSetID]) REFERENCES [dbo].[MappingSet] ([MappingSetID]) ON DELETE CASCADE ON UPDATE CASCADE
);
























GO



GO
CREATE NONCLUSTERED INDEX [FK_MappingSetMapping_Mapping]
    ON [dbo].[MappingSetMapping]([MappingID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies which mappings are part of the MappingSet', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MappingSetMapping';


GO

GO
CREATE TRIGGER [dbo].[MappingSetMapping_AfterUpdate]
ON [dbo].[MappingSetMapping]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingSetMapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSetMapping tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingSetID = tbl_ins.MappingSetID
		AND tbl.MappingID = tbl_ins.MappingID

	
END
GO
CREATE NONCLUSTERED INDEX [FK_MappingSetMapping_MappingSet]
    ON [dbo].[MappingSetMapping]([MappingSetID] ASC);


GO



GO



GO



GO



GO


