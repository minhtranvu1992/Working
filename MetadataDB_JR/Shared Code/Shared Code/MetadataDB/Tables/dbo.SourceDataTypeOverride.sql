CREATE TABLE [dbo].[SourceDataTypeOverride] (
    [ConnectionClassCategoryID] VARCHAR (40)  NOT NULL,
    [DomainDataTypeID]          VARCHAR (40)  NOT NULL,
    [OverrideDataType]          VARCHAR (40)  NOT NULL,
    [UpdatedBy]                 VARCHAR (100) CONSTRAINT [DF__SourceDat__Updat__567ED357] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]           DATETIME      CONSTRAINT [DF__SourceDat__Updat__5772F790] DEFAULT (getdate()) NULL,
    [CreatedBy]                 VARCHAR (100) CONSTRAINT [DF__SourceDat__Creat__58671BC9] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]           DATETIME      CONSTRAINT [DF__SourceDat__Creat__595B4002] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_SourceDataTypeOverride] PRIMARY KEY CLUSTERED ([ConnectionClassCategoryID] ASC, [DomainDataTypeID] ASC)
);




GO

GO
CREATE Trigger [dbo].[SourceDataTypeOverride_AfterUpdate]
On [dbo].[SourceDataTypeOverride]
AFTER UPDATE
As
Begin
    UPDATE dbo.SourceDataTypeOverride
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.SourceDataTypeOverride tbl
        INNER Join inserted tbl_ins
        On  tbl.ConnectionClassCategoryID = tbl_ins.ConnectionClassCategoryID
       And tbl.DomainDataTypeID = tbl_ins.DomainDataTypeID


End