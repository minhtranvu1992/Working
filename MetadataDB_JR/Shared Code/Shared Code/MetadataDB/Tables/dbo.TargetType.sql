CREATE TABLE [dbo].[TargetType] (
    [TargetTypeID]    VARCHAR (40)  NOT NULL,
    [TargetType]      VARCHAR (100) NULL,
    [CreatedBy]       VARCHAR (100) CONSTRAINT [DF__TargetTyp__Creat__6991A7CB] DEFAULT (suser_name()) NULL,
    [CreatedDateTime] DATETIME      CONSTRAINT [DF__TargetTyp__Creat__6A85CC04] DEFAULT (getdate()) NULL,
    [UpdatedBy]       VARCHAR (100) CONSTRAINT [DF__TargetTyp__Updat__6B79F03D] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime] DATETIME      CONSTRAINT [DF__TargetTyp__Updat__6C6E1476] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TARGETTYPE] PRIMARY KEY NONCLUSTERED ([TargetTypeID] ASC)
);






















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'This specifies which type of object is the target
This could be an Export Object, or a DW Object', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TargetType';


GO

GO
CREATE TRIGGER [dbo].[TargetType_AfterUpdate]
ON [dbo].[TargetType]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.TargetType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.TargetType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.TargetTypeID = tbl_ins.TargetTypeID

	
END
GO



GO



GO



GO



GO


