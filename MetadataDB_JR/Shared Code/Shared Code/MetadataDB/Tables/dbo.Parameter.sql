CREATE TABLE [dbo].[Parameter] (
    [ParameterName]   VARCHAR (40)   NOT NULL,
    [ParameterValue]  VARCHAR (MAX)  NULL,
    [ParameterDesc]   VARCHAR (4000) NULL,
    [CreatedBy]       VARCHAR (100)  CONSTRAINT [DF__Parameter__Creat__4EDDB18F] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME       CONSTRAINT [DF__Parameter__Creat__4FD1D5C8] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100)  CONSTRAINT [DF__Parameter__Updat__50C5FA01] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME       CONSTRAINT [DF__Parameter__Updat__51BA1E3A] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_PARAMETER] PRIMARY KEY NONCLUSTERED ([ParameterName] ASC)
);








GO

GO
CREATE TRIGGER [dbo].[Parameter_AfterUpdate]
ON [dbo].[Parameter]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Parameter
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Parameter tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ParameterName = tbl_ins.ParameterName

	
END