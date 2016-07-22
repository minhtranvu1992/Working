CREATE TABLE [dbo].[BuildScripts] (
    [DatabaseLayer]      VARCHAR (40)  NOT NULL,
    [IsPostDeployScript] BIT           NOT NULL,
    [ScriptOrder]        INT           NOT NULL,
    [IncludeInBuild]     BIT           NULL,
    [ScriptSQL]          VARCHAR (MAX) NOT NULL,
    [UpdatedBy]          VARCHAR (100) CONSTRAINT [DF__BuildScri__Updat__7AF13DF7] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]    DATETIME      CONSTRAINT [DF__BuildScri__Updat__7BE56230] DEFAULT (getdate()) NULL,
    [CreatedBy]          VARCHAR (100) CONSTRAINT [DF__BuildScri__Creat__7CD98669] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]    DATETIME      CONSTRAINT [DF__BuildScri__Creat__7DCDAAA2] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_BUILDSCRIPTS] PRIMARY KEY CLUSTERED ([DatabaseLayer] ASC, [IsPostDeployScript] ASC, [ScriptOrder] ASC)
);






GO

GO

CREATE Trigger [dbo].[BuildScripts_AfterUpdate]
On [dbo].[BuildScripts]
AFTER UPDATE
As
Begin
    UPDATE dbo.BuildScripts
        Set UpdatedDateTime = GETDATE(),
        UpdatedBy = SUSER_NAME()
    FROM dbo.BuildScripts tbl
        INNER Join inserted tbl_ins
        On  tbl.DatabaseLayer = tbl_ins.DatabaseLayer
       And tbl.IsPostDeployScript = tbl_ins.IsPostDeployScript
       And tbl.ScriptOrder = tbl_ins.ScriptOrder


End