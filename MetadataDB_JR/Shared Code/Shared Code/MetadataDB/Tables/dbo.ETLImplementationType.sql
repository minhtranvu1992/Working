CREATE TABLE [dbo].[ETLImplementationType] (
    [ETLImplementationTypeID] VARCHAR (40)  NOT NULL,
    [ETLImplementationType]   VARCHAR (100) NOT NULL,
    [ETLImplementationClass]  VARCHAR (100) NOT NULL,
    [ExtractProcessType]      VARCHAR (100) NULL,
    [MappingColumnsRequired]  BIT           NULL,
    [CreatedBy]               VARCHAR (100) CONSTRAINT [DF__ETLImplem__Creat__3429BB53] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]         DATETIME      CONSTRAINT [DF__ETLImplem__Creat__351DDF8C] DEFAULT (getdate()) NULL,
    [UpdatedBy]               VARCHAR (100) CONSTRAINT [DF__ETLImplem__Updat__361203C5] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]         DATETIME      CONSTRAINT [DF__ETLImplem__Updat__370627FE] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ETLIMPLEMENTATIONTYPE] PRIMARY KEY NONCLUSTERED ([ETLImplementationTypeID] ASC)
);






















GO

GO
CREATE TRIGGER [dbo].[ETLImplementationType_AfterUpdate]
ON [dbo].[ETLImplementationType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ETLImplementationType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ETLImplementationType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ETLImplementationTypeID = tbl_ins.ETLImplementationTypeID

	
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Indicates what type of strategy we are using to generate code for the ETL
This should align with the connection and the direction in which the data is flowing', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ETLImplementationType';


GO



GO



GO



GO



GO


