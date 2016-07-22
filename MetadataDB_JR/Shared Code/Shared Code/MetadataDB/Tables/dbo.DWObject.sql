CREATE TABLE [dbo].[DWObject] (
    [DWObjectID]             AS             (CONVERT([varchar](100),([DWLayerID]+'_')+[DWObjectName])) PERSISTED NOT NULL,
    [DWObjectTypeID]         VARCHAR (40)   NULL,
    [DWObjectBuildTypeID]    VARCHAR (40)   NULL,
    [DWLayerID]              VARCHAR (40)   NULL,
    [DWObjectDesc]           VARCHAR (4000) NOT NULL,
    [DWObjectName]           VARCHAR (100)  NOT NULL,
    [DWObjectImplementation] VARCHAR (40)   NULL,
    [IncludeInBuild]         BIT            NULL,
    [CreatedBy]              VARCHAR (100)  CONSTRAINT [DF__DWObject__Create__28B808A7] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]        DATETIME       CONSTRAINT [DF__DWObject__Create__29AC2CE0] DEFAULT (getdate()) NULL,
    [UpdatedBy]              VARCHAR (100)  CONSTRAINT [DF__DWObject__Update__2AA05119] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]        DATETIME       CONSTRAINT [DF__DWObject__Update__2B947552] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DWOBJECT] PRIMARY KEY NONCLUSTERED ([DWObjectID] ASC),
    CONSTRAINT [FK_DWObject_DWLayer] FOREIGN KEY ([DWLayerID]) REFERENCES [dbo].[DWLayer] ([DWLayerID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_DWObject_DWObjectBuildType] FOREIGN KEY ([DWObjectBuildTypeID]) REFERENCES [dbo].[DWObjectBuildType] ([DWObjectBuildTypeID]) ON UPDATE CASCADE,
    CONSTRAINT [FK_DWObject_DWObjectType] FOREIGN KEY ([DWObjectTypeID]) REFERENCES [dbo].[DWObjectType] ([DWObjectTypeID]) ON UPDATE CASCADE
);










GO
CREATE NONCLUSTERED INDEX [FK_DWObject_DWObjectType]
    ON [dbo].[DWObject]([DWObjectTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DWObject_DWObjectBuildType]
    ON [dbo].[DWObject]([DWObjectBuildTypeID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DWObject_DWLayer]
    ON [dbo].[DWObject]([DWLayerID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_DWObject]
    ON [dbo].[DWObject]([DWLayerID] ASC, [DWObjectName] ASC);


GO

GO
CREATE TRIGGER [dbo].[DWObject_AfterUpdate]
ON [dbo].[DWObject]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObject
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObject tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectID = tbl_ins.DWObjectID

	
END