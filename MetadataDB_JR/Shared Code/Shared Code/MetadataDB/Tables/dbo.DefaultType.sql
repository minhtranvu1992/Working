CREATE TABLE [dbo].[DefaultType] (
    [DefaultTypeID]   VARCHAR (40)  NOT NULL,
    [DefaultType]     VARCHAR (100) NOT NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__DefaultTy__Creat__15A53433] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__DefaultTy__Creat__1699586C] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__DefaultTy__Updat__178D7CA5] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__DefaultTy__Updat__1881A0DE] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DEFAULTTYPE] PRIMARY KEY CLUSTERED ([DefaultTypeID] ASC)
);




GO

GO


CREATE Trigger [dbo].[DefaultType_AfterUpdate]
On [dbo].[DefaultType]
AFTER UPDATE
As
Begin
    UPDATE dbo.DefaultType
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.DefaultType tbl
        INNER Join inserted tbl_ins
        On  tbl.DefaultTypeID = tbl_ins.DefaultTypeID


End