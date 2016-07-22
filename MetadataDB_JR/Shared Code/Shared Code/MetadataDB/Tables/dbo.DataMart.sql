CREATE TABLE [dbo].[DataMart] (
    [DataMartID]                 VARCHAR (40)  NOT NULL,
    [DataMartName]               VARCHAR (100) NULL,
    [DataMartSchemaAbbreviation] VARCHAR (40)  NULL,
    [IncludeInBuild]             BIT           NULL,
    [CreatedBy]                  VARCHAR (100) CONSTRAINT [DF__DataMart__Create__0A338187] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]            DATETIME      CONSTRAINT [DF__DataMart__Create__0B27A5C0] DEFAULT (getdate()) NULL,
    [UpdatedBy]                  VARCHAR (100) CONSTRAINT [DF__DataMart__Update__0C1BC9F9] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]            DATETIME      CONSTRAINT [DF__DataMart__Update__0D0FEE32] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DATAMART] PRIMARY KEY NONCLUSTERED ([DataMartID] ASC)
);












GO

GO
CREATE TRIGGER [dbo].[DataMart_AfterUpdate]
ON [dbo].[DataMart]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DataMart
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMart tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DataMartID = tbl_ins.DataMartID

	
END