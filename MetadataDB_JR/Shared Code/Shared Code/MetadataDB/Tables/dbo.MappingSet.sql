CREATE TABLE [dbo].[MappingSet] (
    [MappingSetID]     VARCHAR (40)   NOT NULL,
    [MappingSetDesc]   VARCHAR (4000) NOT NULL,
    [MappingSetSource] VARCHAR (100)  NULL,
    [MappingSetTarget] VARCHAR (100)  NULL,
    [CreatedBy]        VARCHAR (100)  CONSTRAINT [DF__MappingSe__Creat__473C8FC7] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]  DATETIME       CONSTRAINT [DF__MappingSe__Creat__4830B400] DEFAULT (getdate()) NULL,
    [UpdatedBy]        VARCHAR (100)  CONSTRAINT [DF__MappingSe__Updat__4924D839] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]  DATETIME       CONSTRAINT [DF__MappingSe__Updat__4A18FC72] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MAPPINGSET] PRIMARY KEY NONCLUSTERED ([MappingSetID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'A Logical Grouping of a set of mappings. For example
1) Extract and Delivery from one source system to the data warehouse
2) Extract and Delivery from the base data warehouse layer to the summary layers
3) Export from the data warehouse an Export Schema or to a flat file', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MappingSet';


GO

GO
CREATE TRIGGER [dbo].[MappingSet_AfterUpdate]
ON [dbo].[MappingSet]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingSet
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSet tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingSetID = tbl_ins.MappingSetID

	
END
GO



GO



GO



GO



GO


