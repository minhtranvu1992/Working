CREATE TABLE [dbo].[StagingObject] (
    [StagingObjectID]     AS             (CONVERT([varchar](100),([StagingOwnerID]+'_')+[StagingObjectName])) PERSISTED NOT NULL,
    [IncludeInBuild]      BIT            NOT NULL,
    [StagingOwnerID]      VARCHAR (40)   NOT NULL,
    [StagingObjectDesc]   VARCHAR (4000) NOT NULL,
    [StagingObjectName]   VARCHAR (100)  NOT NULL,
    [ProcessDeletes]      BIT            NOT NULL,
    [StagingObjectTypeID] VARCHAR (40)   NULL,
    [UpdatedBy]           VARCHAR (100)  CONSTRAINT [DF__StagingOb__Updat__5E1FF51F] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME       CONSTRAINT [DF__StagingOb__Updat__5F141958] DEFAULT (getdate()) NULL,
    [CreatedBy]           VARCHAR (100)  CONSTRAINT [DF__StagingOb__Creat__60083D91] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME       CONSTRAINT [DF__StagingOb__Creat__60FC61CA] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_StagingObject] PRIMARY KEY NONCLUSTERED ([StagingObjectID] ASC),
    CONSTRAINT [FK_StagingObject_StagingObjectType] FOREIGN KEY ([StagingObjectTypeID]) REFERENCES [dbo].[StagingObjectType] ([StagingObjectTypeID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_StagingObject_StagingOwner] FOREIGN KEY ([StagingOwnerID]) REFERENCES [dbo].[StagingOwner] ([StagingOwnerID]) ON DELETE CASCADE ON UPDATE CASCADE
);


















GO



GO



GO



GO

GO


CREATE Trigger [dbo].[StagingObject_AfterUpdate]
On [dbo].[StagingObject]
AFTER UPDATE
As
Begin
    UPDATE dbo.StagingObject
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.StagingObject tbl
        INNER Join inserted tbl_ins
        On  tbl.StagingObjectID = tbl_ins.StagingObjectID


End
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies the logical object to which we are exporting
Could be the LogicalFlatFile, or a logical table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StagingObject';


GO



GO



GO



GO



GO


