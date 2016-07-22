USE [DWStaging]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdate_SimpleLoad]    Script Date: 8/05/2014 10:26:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.uspUpdate_SimpleLoad', 'p') IS NULL
    EXEC ('CREATE PROCEDURE dbo.uspUpdate_SimpleLoad AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[uspUpdate_SimpleLoad] AS
SET NOCOUNT ON
BEGIN
	SELECT CAST(0 AS INT) AS 'RowsInserted',
	CAST(0 AS INT) AS 'RowsDeleted',
	CAST(0 AS INT) AS 'RowsUpdated'
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.STG_SimpleLoad', 'U') IS NOT NULL
BEGIN
	DROP TABLE [dbo].[STG_SimpleLoad]
END
GO
CREATE TABLE [dbo].[STG_SimpleLoad](
	[TestID] [int] NULL,
	[TestName] [nvarchar](100) NULL,
	[LoadTime] [datetime] NULL,
	[amount] [decimal](36, 2) NULL,
	[isFlag] [bit] NULL,
	[StagingJobID] [int] NULL
) ON [PRIMARY]

GO
