CREATE TABLE [dbo].[DWObjectType] (
    [DWObjectTypeID]            VARCHAR (40)  NOT NULL,
    [DWObjectType]              VARCHAR (100) NOT NULL,
    [DWObjectLoadLogic]         VARCHAR (40)  NULL,
    [DWObjectGroup]             VARCHAR (40)  NULL,
    [DWObjectGroupAbbreviation] VARCHAR (40)  NULL,
    [CreatedBy]                 VARCHAR (100) CONSTRAINT [DF__DWObjectT__Creat__30592A6F] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]           DATETIME      CONSTRAINT [DF__DWObjectT__Creat__314D4EA8] DEFAULT (getdate()) NULL,
    [UpdatedBy]                 VARCHAR (100) CONSTRAINT [DF__DWObjectT__Updat__324172E1] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]           DATETIME      CONSTRAINT [DF__DWObjectT__Updat__3335971A] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DWOBJECTTYPE] PRIMARY KEY NONCLUSTERED ([DWObjectTypeID] ASC)
);
























GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates the type of object
ObjectTypeID is Dim-Type2 & ObjectGroup is Dimension
ObjectTypeID is Fact-Snapshot & ObjectGroup is Fact', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DWObjectType';


GO

GO

CREATE TRIGGER [dbo].[DWObjectType_AfterUpdate]
ON [dbo].[DWObjectType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObjectType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectTypeID = tbl_ins.DWObjectTypeID

	
END
GO



GO



GO



GO



GO


