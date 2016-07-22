CREATE TABLE [dbo].[Frequency] (
    [FrequencyID]     VARCHAR (40)  NOT NULL,
    [Frequency]       VARCHAR (100) NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__Frequency__Creat__37FA4C37] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__Frequency__Creat__38EE7070] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__Frequency__Updat__39E294A9] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__Frequency__Updat__3AD6B8E2] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_FREQUENCY] PRIMARY KEY NONCLUSTERED ([FrequencyID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies the frequency the data is required (Intraday, Daily, Weekly, Monthly, etc)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Frequency';


GO

GO
CREATE TRIGGER [dbo].[Frequency_AfterUpdate]
ON [dbo].[Frequency]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Frequency
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Frequency tbl
		INNER JOIN inserted tbl_ins
		ON tbl.FrequencyID = tbl_ins.FrequencyID

	
END
GO



GO



GO



GO



GO


