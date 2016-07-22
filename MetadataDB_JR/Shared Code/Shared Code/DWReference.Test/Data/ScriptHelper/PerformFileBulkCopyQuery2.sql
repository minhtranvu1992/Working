USE [DWStaging]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.PerformFileBulkCopy', 'U') IS NOT NULL
BEGIN
	DROP TABLE [dbo].[PerformFileBulkCopy]
END
GO
CREATE TABLE [dbo].[PerformFileBulkCopy](
	[TestID] [int] NULL,
	[Test.Name] [nvarchar](100) NULL,
	[LoadTime] [datetime] NULL,
	[amount] [decimal](36, 2) NULL,
	[isFlag] [bit] NULL,
	[StagingJobID] [int] NULL
) ON [PRIMARY]

GO
