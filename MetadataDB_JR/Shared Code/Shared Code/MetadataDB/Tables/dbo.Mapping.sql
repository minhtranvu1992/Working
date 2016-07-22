CREATE TABLE [dbo].[Mapping] (
    [MappingID]                      VARCHAR (100)  NOT NULL,
    [TargetConnectionID]             VARCHAR (40)   NULL,
    [AlternatePackageName]           VARCHAR (100)  NULL,
    [DefaultSourceChangeTypeID]      VARCHAR (40)   NULL,
    [IncludeInBuild]                 BIT            NULL,
    [SourceObjectLogic]              VARCHAR (MAX)  NULL,
    [TargetTypeID]                   VARCHAR (40)   NULL,
    [DefaultFrequencyID]             VARCHAR (40)   NULL,
    [TargetObjectID]                 VARCHAR (100)  NOT NULL,
    [DefaultRetentionDays]           INT            NULL,
    [DefaultDeleteTypeID]            VARCHAR (40)   NULL,
    [PreMappingLogic]                VARCHAR (MAX)  NULL,
    [PostMappingLogic]               VARCHAR (MAX)  NULL,
    [DeltaLogic]                     VARCHAR (MAX)  NULL,
    [MappingComments]                VARCHAR (4000) NULL,
    [UseDeltaAsLastChangeTime]       BIT            NULL,
    [DefaultETLImplementationTypeID] VARCHAR (40)   NULL,
    [FlatFileFormatString]           VARCHAR (100)  NULL,
    [FlatFileDelimiter]              VARCHAR (40)   NULL,
    [FlatFileHasHeader]              BIT            NULL,
    [FlatFileHasFooter]              BIT            NULL,
    [DateFormatTypeID]               INT            NULL,
    [CreatedBy]                      VARCHAR (100)  CONSTRAINT [DF__Mapping__Created__3BCADD1B] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]                DATETIME       CONSTRAINT [DF__Mapping__Created__3CBF0154] DEFAULT (getdate()) NULL,
    [UpdatedBy]                      VARCHAR (100)  CONSTRAINT [DF__Mapping__Updated__3DB3258D] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]                DATETIME       CONSTRAINT [DF__Mapping__Updated__3EA749C6] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MAPPING] PRIMARY KEY NONCLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_Mapping_Connection] FOREIGN KEY ([TargetConnectionID]) REFERENCES [dbo].[Connection] ([ConnectionID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Mapping_DateFormatType] FOREIGN KEY ([DateFormatTypeID]) REFERENCES [dbo].[DateFormatType] ([DateFormatTypeID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Mapping_DeleteType] FOREIGN KEY ([DefaultDeleteTypeID]) REFERENCES [dbo].[DeleteType] ([DeleteTypeID]),
    CONSTRAINT [FK_Mapping_ETLImplementationType] FOREIGN KEY ([DefaultETLImplementationTypeID]) REFERENCES [dbo].[ETLImplementationType] ([ETLImplementationTypeID]),
    CONSTRAINT [FK_Mapping_Frequency] FOREIGN KEY ([DefaultFrequencyID]) REFERENCES [dbo].[Frequency] ([FrequencyID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Mapping_SourceChangeType] FOREIGN KEY ([DefaultSourceChangeTypeID]) REFERENCES [dbo].[SourceChangeType] ([SourceChangeTypeID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Mapping_TargetType] FOREIGN KEY ([TargetTypeID]) REFERENCES [dbo].[TargetType] ([TargetTypeID]) ON UPDATE CASCADE
);






























GO
CREATE NONCLUSTERED INDEX [FK_Mapping_Connection]
    ON [dbo].[Mapping]([TargetConnectionID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Mapping_SourceChangeType]
    ON [dbo].[Mapping]([DefaultSourceChangeTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Mapping_TargetType]
    ON [dbo].[Mapping]([TargetTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Mapping_Frequency]
    ON [dbo].[Mapping]([DefaultFrequencyID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identifies a mapping template used for ETL which can map to an ExportObject or a DWObject depending on the TargetTypeID
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Mapping';


GO



GO
CREATE NONCLUSTERED INDEX [FK_Mapping_DeleteType]
    ON [dbo].[Mapping]([DefaultDeleteTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_Mapping_ETLImplementationType]
    ON [dbo].[Mapping]([DefaultETLImplementationTypeID] ASC);


GO

GO


CREATE Trigger [dbo].[Mapping_AfterUpdate]
On [dbo].[Mapping]
AFTER UPDATE
As
Begin
    UPDATE dbo.Mapping
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.Mapping tbl
        INNER Join inserted tbl_ins
        On  tbl.MappingID = tbl_ins.MappingID


End
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'By Default when the ETL is generated, the code takes the name of the destination ObjectName. However when we have two ETLs from the same source going into the same Target Table, we need to have an Alternate Name, which is what the name in this field is used for.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Mapping', @level2type = N'COLUMN', @level2name = N'AlternatePackageName';


GO



GO



GO



GO



GO



GO



GO



GO



GO



GO


