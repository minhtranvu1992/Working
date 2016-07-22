CREATE TABLE [dbo].[DWElement] (
    [DWElementID]               AS             (CONVERT([varchar](100),([DWObjectID]+'_')+[DWElementName])) PERSISTED NOT NULL,
    [DWObjectID]                VARCHAR (100)  NOT NULL,
    [EntityLookupObjectID]      VARCHAR (100)  NULL,
    [DomainDataTypeID]          VARCHAR (40)   NULL,
    [DWElementName]             VARCHAR (100)  NOT NULL,
    [DWElementDesc]             VARCHAR (4000) NOT NULL,
    [BusinessKeyOrder]          INT            NULL,
    [InferredMemberLoad]        BIT            NULL,
    [RetainBusinessKey]         BIT            NULL,
    [ErrorOnInvalidBusinessKey] BIT            NULL,
    [ErrorOnMissingBusinessKey] BIT            NULL,
    [CreatedBy]                 VARCHAR (100)  CONSTRAINT [DF__DWElement__Creat__2116E6DF] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]           DATETIME       CONSTRAINT [DF__DWElement__Creat__220B0B18] DEFAULT (getdate()) NULL,
    [UpdatedBy]                 VARCHAR (100)  CONSTRAINT [DF__DWElement__Updat__22FF2F51] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]           DATETIME       CONSTRAINT [DF__DWElement__Updat__23F3538A] DEFAULT (getdate()) NULL,
    [DefaultTypeID]             VARCHAR (40)   NULL,
    [BespokeDefaultLogic]       VARCHAR (MAX)  NULL,
    [SnapshotProcessSeperator]  BIT            NULL,
    CONSTRAINT [PK_DWELEMENT] PRIMARY KEY NONCLUSTERED ([DWElementID] ASC),
    CONSTRAINT [FK_DWElement_DefaultType] FOREIGN KEY ([DefaultTypeID]) REFERENCES [dbo].[DefaultType] ([DefaultTypeID]),
    CONSTRAINT [FK_DWElement_DomainDataType] FOREIGN KEY ([DomainDataTypeID]) REFERENCES [dbo].[DomainDataType] ([DomainDataTypeID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_DWElement_DWObject] FOREIGN KEY ([DWObjectID]) REFERENCES [dbo].[DWObject] ([DWObjectID]) ON DELETE CASCADE ON UPDATE CASCADE
);














GO
CREATE NONCLUSTERED INDEX [FK_DWElement_DWObject]
    ON [dbo].[DWElement]([DWObjectID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_DWElement]
    ON [dbo].[DWElement]([DWObjectID] ASC, [DWElementName] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DWElement_DWObject_EntityLookup]
    ON [dbo].[DWElement]([EntityLookupObjectID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DWElement_DomainDataType]
    ON [dbo].[DWElement]([DomainDataTypeID] ASC);


GO

GO
CREATE TRIGGER [dbo].[DWElement_AfterUpdate]
ON [dbo].[DWElement]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWElementID = tbl_ins.DWElementID

	
END
GO
CREATE NONCLUSTERED INDEX [FK_DWElement_DefaultType]
    ON [dbo].[DWElement]([DefaultTypeID] ASC);

