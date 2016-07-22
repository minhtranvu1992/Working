CREATE TABLE [dbo].[DWLayer] (
    [DWLayerID]                VARCHAR (40)   NOT NULL,
    [DWLayerDesc]              VARCHAR (4000) NOT NULL,
    [DWLayerName]              VARCHAR (100)  NOT NULL,
    [DWLayerAbbreviation]      VARCHAR (40)   NULL,
    [DWLayerType]              VARCHAR (40)   NULL,
    [ExtractLayerAbbreviation] VARCHAR (40)   NULL,
    [CreatedBy]                VARCHAR (100)  CONSTRAINT [DF__DWLayer__Created__24E777C3] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]          DATETIME       CONSTRAINT [DF__DWLayer__Created__25DB9BFC] DEFAULT (getdate()) NULL,
    [UpdatedBy]                VARCHAR (100)  CONSTRAINT [DF__DWLayer__Updated__26CFC035] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]          DATETIME       CONSTRAINT [DF__DWLayer__Updated__27C3E46E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DWLAYER] PRIMARY KEY NONCLUSTERED ([DWLayerID] ASC)
);










GO

GO
CREATE TRIGGER [dbo].[DWLayer_AfterUpdate]
ON [dbo].[DWLayer]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWLayer
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWLayer tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWLayerID = tbl_ins.DWLayerID

	
END