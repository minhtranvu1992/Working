CREATE TABLE [dbo].[StagingObjectType] (
    [StagingObjectTypeID] VARCHAR (40)  NOT NULL,
    [StagingObjectType]   VARCHAR (100) NOT NULL,
    [MappingRequired]     BIT           NULL,
    [CreatedBy]           VARCHAR (100) CONSTRAINT [DF__StagingOb__Creat__61F08603] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]     DATETIME      CONSTRAINT [DF__StagingOb__Creat__62E4AA3C] DEFAULT (getdate()) NULL,
    [UpdatedBy]           VARCHAR (100) CONSTRAINT [DF__StagingOb__Updat__63D8CE75] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]     DATETIME      CONSTRAINT [DF__StagingOb__Updat__64CCF2AE] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_StagingObjectTYPE] PRIMARY KEY NONCLUSTERED ([StagingObjectTypeID] ASC)
);
















GO

GO
CREATE TRIGGER [dbo].[StagingObjectType_AfterUpdate]
ON dbo.StagingObjectType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.StagingObjectType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.StagingObjectType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.StagingObjectTypeID = tbl_ins.StagingObjectTypeID

	
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicates the pattern used for constructing the staging objects.
Batch - ODS table will receive batch loads and will be loaded using either a flat file or an DB Extract pulled using StagingManager
XMLMessage - ODS table will be pushed xml, load is not controlled by StagingManager and no records are required in StagingControl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StagingObjectType';


GO



GO



GO



GO


