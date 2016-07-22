CREATE TABLE [dbo].[StagingElement] (
    [StagingElementID]    AS             (CONVERT([varchar](100),([StagingObjectID]+'_')+[StagingElementName])) PERSISTED NOT NULL,
    [StagingObjectID]     VARCHAR (100)  NOT NULL,
    [StagingElementOrder] INT            NOT NULL,
    [StagingElementName]  VARCHAR (100)  NOT NULL,
    [StagingElementDesc]  VARCHAR (4000) NOT NULL,
    [BusinessKeyOrder]    INT            NULL,
    [IsMandatory]         BIT            NULL,
    [DomainDataTypeID]    VARCHAR (40)   NOT NULL,
    [UpdatedBy]           VARCHAR (100)  CONSTRAINT [DF__StagingEl__Updat__5A4F643B] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME       CONSTRAINT [DF__StagingEl__Updat__5B438874] DEFAULT (getdate()) NULL,
    [CreatedBy]           VARCHAR (100)  CONSTRAINT [DF__StagingEl__Creat__5C37ACAD] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME       CONSTRAINT [DF__StagingEl__Creat__5D2BD0E6] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_STAGINGELEMENT] PRIMARY KEY CLUSTERED ([StagingElementID] ASC),
    CONSTRAINT [FK_StagingElement_DomainDataType] FOREIGN KEY ([DomainDataTypeID]) REFERENCES [dbo].[DomainDataType] ([DomainDataTypeID]),
    CONSTRAINT [FK_StagingElement_StagingObject] FOREIGN KEY ([StagingObjectID]) REFERENCES [dbo].[StagingObject] ([StagingObjectID]) ON DELETE CASCADE ON UPDATE CASCADE
);


















GO
CREATE NONCLUSTERED INDEX [FK_StagingElement_SourceDataType]
    ON [dbo].[StagingElement]([DomainDataTypeID] ASC);




GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_StagingElement2]
    ON [dbo].[StagingElement]([StagingObjectID] ASC, [StagingElementOrder] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_StagingElement]
    ON [dbo].[StagingElement]([StagingObjectID] ASC, [StagingElementName] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_StagingElement_StagingObject]
    ON [dbo].[StagingElement]([StagingObjectID] ASC);


GO

GO


CREATE Trigger [dbo].[StagingElement_AfterUpdate]
On [dbo].[StagingElement]
AFTER UPDATE
As
Begin
    UPDATE dbo.StagingElement
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.StagingElement tbl
        INNER Join inserted tbl_ins
        On  tbl.StagingElementID = tbl_ins.StagingElementID


End
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies the individual Element to which we are exporting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StagingElement';


GO



GO



GO



GO



GO


