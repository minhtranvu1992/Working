CREATE TABLE [dbo].[MappingElement] (
    [MappingID]          VARCHAR (100)  NOT NULL,
    [SourceElementLogic] VARCHAR (MAX)  NULL,
    [TargetElementID]    VARCHAR (100)  NOT NULL,
    [MappingComments]    VARCHAR (4000) NULL,
    [CreatedBy]          VARCHAR (100)  CONSTRAINT [DF__MappingEl__Creat__3F9B6DFF] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]    DATETIME       CONSTRAINT [DF__MappingEl__Creat__408F9238] DEFAULT (getdate()) NULL,
    [UpdatedBy]          VARCHAR (100)  CONSTRAINT [DF__MappingEl__Updat__4183B671] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]    DATETIME       CONSTRAINT [DF__MappingEl__Updat__4277DAAA] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_MAPPINGELEMENT] PRIMARY KEY NONCLUSTERED ([MappingID] ASC, [TargetElementID] ASC),
    CONSTRAINT [FK_MappingElement_Mapping] FOREIGN KEY ([MappingID]) REFERENCES [dbo].[Mapping] ([MappingID]) ON DELETE CASCADE ON UPDATE CASCADE
);
























GO
CREATE NONCLUSTERED INDEX [FK_MappingElement_Mapping]
    ON [dbo].[MappingElement]([MappingID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies logic for mapping to individual target element, which can be a DWElementID or an ExportElementID depending on the related TargetType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MappingElement';


GO

GO
CREATE TRIGGER [dbo].[MappingElement_AfterUpdate]
ON [dbo].[MappingElement]
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingID = tbl_ins.MappingID
		AND tbl.TargetElementID = tbl_ins.TargetElementID

	
END
GO



GO



GO



GO



GO


