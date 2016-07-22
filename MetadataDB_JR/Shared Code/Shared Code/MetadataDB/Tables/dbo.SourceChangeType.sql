CREATE TABLE [dbo].[SourceChangeType] (
    [SourceChangeTypeID] VARCHAR (40)  NOT NULL,
    [SourceChangeType]   VARCHAR (100) NULL,
    [VariablesRequired]  VARCHAR (MAX) NULL,
    [WindowSize]         INT           NULL,
    [CreatedBy]          VARCHAR (100) CONSTRAINT [DF__SourceCha__Creat__52AE4273] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]    DATETIME      CONSTRAINT [DF__SourceCha__Creat__53A266AC] DEFAULT (getdate()) NULL,
    [UpdatedBy]          VARCHAR (100) CONSTRAINT [DF__SourceCha__Updat__54968AE5] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]    DATETIME      CONSTRAINT [DF__SourceCha__Updat__558AAF1E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_SOURCECHANGETYPE] PRIMARY KEY NONCLUSTERED ([SourceChangeTypeID] ASC)
);


























GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies the type of mapping that is being used.
Types would include
* Snapshot
* Window
* Delta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SourceChangeType';


GO

GO
CREATE TRIGGER [dbo].[SourceChangeType_AfterUpdate]
ON [dbo].[SourceChangeType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.SourceChangeType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.SourceChangeType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.SourceChangeTypeID = tbl_ins.SourceChangeTypeID

	
END
GO



GO



GO



GO



GO


