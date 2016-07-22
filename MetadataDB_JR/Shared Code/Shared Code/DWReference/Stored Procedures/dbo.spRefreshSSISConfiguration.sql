-- =============================================
-- Author:		Olof Szymczak
-- Create date: 2012-06-20
-- Description:	Refresh SSISConfiguration when a restore has occured
-- =============================================
CREATE PROCEDURE [dbo].[spRefreshSSISConfiguration]
AS
BEGIN

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_SourceControl_SSISConfiguration]') AND parent_object_id = OBJECT_ID(N'[dbo].[SourceControl]'))
	ALTER TABLE [dbo].[SourceControl] DROP CONSTRAINT [FK_SourceControl_SSISConfiguration]


DELETE FROM [dbo].[SSISConfiguration]
SET IDENTITY_INSERT [dbo].[SSISConfiguration] ON

INSERT INTO dbo.SSISConfiguration ([SSISConfigurationID]
      ,[ConfigurationFilter]
      ,[ConfiguredValue]
      ,[PackagePath]
      ,[ConfiguredValueType]
      ,[Description]
)
SELECT [SSISConfigurationID]
      ,[ConfigurationFilter]
      ,[ConfiguredValue]
      ,[PackagePath]
      ,[ConfiguredValueType]
      ,[Description]
FROM dbo.SSISConfigurationSource

SET IDENTITY_INSERT [dbo].[SSISConfiguration] OFF

ALTER TABLE [dbo].[SourceControl]  WITH CHECK ADD  CONSTRAINT [FK_SourceControl_SSISConfiguration] FOREIGN KEY([SSISConfigurationID])
REFERENCES [dbo].[SSISConfiguration] ([SSISConfigurationID])

ALTER TABLE [dbo].[SourceControl] CHECK CONSTRAINT [FK_SourceControl_SSISConfiguration]

END

