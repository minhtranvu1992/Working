CREATE TABLE [dbo].[DataMartDWElement] (
    [DWElementID]     VARCHAR (100) NOT NULL,
    [DataMartID]      VARCHAR (40)  NOT NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__DataMartD__Creat__0E04126B] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__DataMartD__Creat__0EF836A4] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__DataMartD__Updat__0FEC5ADD] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__DataMartD__Updat__10E07F16] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DATAMARTDWELEMENT] PRIMARY KEY NONCLUSTERED ([DWElementID] ASC, [DataMartID] ASC),
    CONSTRAINT [FK_DWElement_DataMartPortal] FOREIGN KEY ([DWElementID]) REFERENCES [dbo].[DWElement] ([DWElementID]) ON DELETE CASCADE ON UPDATE CASCADE
);








GO
CREATE NONCLUSTERED INDEX [FK_DWElement_DataMartPortal]
    ON [dbo].[DataMartDWElement]([DWElementID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DataMartPortal_DataMart]
    ON [dbo].[DataMartDWElement]([DataMartID] ASC);


GO

GO
CREATE TRIGGER [dbo].[DataMartDWElement_AfterUpdate]
ON [dbo].[DataMartDWElement]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DataMartDWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMartDWElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWElementID = tbl_ins.DWElementID
		AND tbl.DataMartID = tbl_ins.DataMartID

	
END
GO
CREATE NONCLUSTERED INDEX [FK_DataMartDWElement_DWElement]
    ON [dbo].[DataMartDWElement]([DWElementID] ASC);


GO
CREATE NONCLUSTERED INDEX [FK_DataMartDWElement_DataMart]
    ON [dbo].[DataMartDWElement]([DataMartID] ASC);

