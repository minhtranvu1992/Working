CREATE TABLE [dbo].[DWObjectBuildType] (
    [DWObjectBuildTypeID] VARCHAR (40)  NOT NULL,
    [DWObjectBuildType]   VARCHAR (100) NULL,
    [CreatedBy]           VARCHAR (100) CONSTRAINT [DF__DWObjectB__Creat__2C88998B] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME      CONSTRAINT [DF__DWObjectB__Creat__2D7CBDC4] DEFAULT (getdate()) NULL,
    [UpdatedBy]           VARCHAR (100) CONSTRAINT [DF__DWObjectB__Updat__2E70E1FD] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME      CONSTRAINT [DF__DWObjectB__Updat__2F650636] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DWOBJECTBUILDTYPE] PRIMARY KEY NONCLUSTERED ([DWObjectBuildTypeID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies whether the logical object will be built as a table or as a view.
Would be used primarily for secondary logic, not population of the base layer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DWObjectBuildType';


GO

GO
CREATE TRIGGER [dbo].[DWObjectBuildType_AfterUpdate]
ON [dbo].[DWObjectBuildType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObjectBuildType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectBuildType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectBuildTypeID = tbl_ins.DWObjectBuildTypeID

	
END
GO



GO



GO



GO



GO


