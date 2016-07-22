CREATE TABLE [dbo].[StagingOwner] (
    [StagingOwnerID]      VARCHAR (40)  NOT NULL,
    [StagingOwner]        VARCHAR (100) NULL,
    [StagingOwnerSuffix]  VARCHAR (40)  NULL,
    [StagingOwnderPrefix] VARCHAR (40)  NOT NULL,
    [OwnerType]           VARCHAR (40)  NOT NULL,
    [UpdatedBy]           VARCHAR (100) CONSTRAINT [DF__StagingOw__Updat__65C116E7] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME      CONSTRAINT [DF__StagingOw__Updat__66B53B20] DEFAULT (getdate()) NULL,
    [CreatedBy]           VARCHAR (100) CONSTRAINT [DF__StagingOw__Creat__67A95F59] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME      CONSTRAINT [DF__StagingOw__Creat__689D8392] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_STAGINGOWNER] PRIMARY KEY CLUSTERED ([StagingOwnerID] ASC)
);


















GO

GO


CREATE Trigger [dbo].[StagingOwner_AfterUpdate]
On [dbo].[StagingOwner]
AFTER UPDATE
As
Begin
    UPDATE dbo.StagingOwner
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.StagingOwner tbl
        INNER Join inserted tbl_ins
        On  tbl.StagingOwnerID = tbl_ins.StagingOwnerID


End
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This specifies the system to which we are exporting data
e.g. Logility', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StagingOwner';


GO



GO



GO



GO



GO


