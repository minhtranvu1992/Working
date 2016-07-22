CREATE TABLE [dbo].[DomainDataType] (
    [DomainDataTypeID]        VARCHAR (40)   NOT NULL,
    [DomainDataTypeName]      VARCHAR (100)  NULL,
    [DomainDataTypeDesc]      VARCHAR (4000) NULL,
    [DataType]                VARCHAR (40)   NULL,
    [FlatFileStagingDataType] VARCHAR (40)   NULL,
    [CreatedBy]               VARCHAR (100)  CONSTRAINT [DF__DomainDat__Creat__1D4655FB] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]         DATETIME       CONSTRAINT [DF__DomainDat__Creat__1E3A7A34] DEFAULT (getdate()) NULL,
    [UpdatedBy]               VARCHAR (100)  CONSTRAINT [DF__DomainDat__Updat__1F2E9E6D] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]         DATETIME       CONSTRAINT [DF__DomainDat__Updat__2022C2A6] DEFAULT (getdate()) NULL,
    [DomainDefaultValue]      VARCHAR (18)   NULL,
    CONSTRAINT [PK_DOMAINDATATYPE] PRIMARY KEY NONCLUSTERED ([DomainDataTypeID] ASC)
);










GO

GO
CREATE TRIGGER [dbo].[DomainDataType_AfterUpdate]
ON [dbo].[DomainDataType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DomainDataType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DomainDataType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DomainDataTypeID = tbl_ins.DomainDataTypeID

	
END