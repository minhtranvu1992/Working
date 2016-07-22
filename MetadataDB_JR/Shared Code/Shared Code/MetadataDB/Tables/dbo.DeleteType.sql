CREATE TABLE [dbo].[DeleteType] (
    [DeleteTypeID]    VARCHAR (40)  NOT NULL,
    [DeleteType]      VARCHAR (100) NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__DeleteTyp__Creat__1975C517] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__DeleteTyp__Creat__1A69E950] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__DeleteTyp__Updat__1B5E0D89] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__DeleteTyp__Updat__1C5231C2] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DELETETYPE] PRIMARY KEY NONCLUSTERED ([DeleteTypeID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies if and how deletes are handled
None - no calculation of Deletes
DeleteOnMissing - Assume any missing records from the ETL are deletes
FullSnapshot - Periodically Extract list of primary keys from source to calculate deleted records.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeleteType';


GO

GO
CREATE TRIGGER [dbo].[DeleteType_AfterUpdate]
ON [dbo].[DeleteType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DeleteType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DeleteType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DeleteTypeID = tbl_ins.DeleteTypeID

	
END
GO



GO



GO



GO



GO


