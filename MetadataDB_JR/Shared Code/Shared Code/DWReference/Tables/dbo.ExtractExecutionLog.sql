CREATE TABLE [dbo].[ExtractExecutionLog] (
    [ExtractExecutionLogID]     INT              IDENTITY (1, 1) NOT NULL,
    [ExtractJobID]              INT              NULL,
    [StartTime]                 DATETIME         NULL,
    [EndTime]                   DATETIME         NULL,
    [ManagerGUID]               UNIQUEIDENTIFIER NULL,
    [SuccessFlag]               INT              NULL,
    [CompletedFlag]             INT              NULL,
    [MessageSource]             VARCHAR (1000)   NULL,
    [Message]                   VARCHAR (MAX)    NULL,
    [RowsExtracted]             INT              NULL,
    [ExtractControlID]          INT              NULL,
    [ExtractPackagePathAndName] VARCHAR (100)    NULL,
    [ExtractPackageName]        VARCHAR (50)     NULL,
    [ExtractPackagePath]        VARCHAR (50)     NULL,
    [SourceControlID]           INT              NULL,
    [SourceControlValue]        VARCHAR (255)    NULL,
    [DestinationControlID]      INT              NULL,
    [DestinationControlValue]   VARCHAR (255)    NULL,
    [SuiteID]                   INT              NULL,
    [SuiteName]                 VARCHAR (50)     NULL,
    [ExecutionOrder]            INT              NULL,
    [ExtractStartTime]          DATETIME         NULL,
    [ExtractEndTime]            DATETIME         NULL,
    [NextExtractStartTime]      DATETIME         NULL,
    CONSTRAINT [PK_ExtractExecutionLog] PRIMARY KEY NONCLUSTERED ([ExtractExecutionLogID] ASC)
);








GO
CREATE CLUSTERED INDEX [IX_ExtractExecutionLog]
    ON [dbo].[ExtractExecutionLog]([ExtractJobID] ASC, [ExtractPackageName] ASC, [SuiteName] ASC);

