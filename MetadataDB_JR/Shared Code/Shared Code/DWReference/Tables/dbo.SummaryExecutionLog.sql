CREATE TABLE [dbo].[SummaryExecutionLog] (
    [SummaryExecutionLogID] INT              IDENTITY (1, 1) NOT NULL,
    [SummaryControlID]      INT              NULL,
    [SummaryJobID]          INT              NULL,
    [DeliveryJobID]         INT              NULL,
    [SummaryPackageName]    VARCHAR (100)    NULL,
    [SummaryTableName]      VARCHAR (100)    NULL,
    [StartTime]             DATETIME         NULL,
    [EndTime]               DATETIME         NULL,
    [ManagerGUID]           UNIQUEIDENTIFIER NULL,
    [SuccessFlag]           INT              NULL,
    [CompletedFlag]         INT              NULL,
    [MessageSource]         VARCHAR (MAX)    NULL,
    [Message]               VARCHAR (MAX)    NULL,
    [ScheduleType]          VARCHAR (50)     NULL,
    [ExecutionOrder]        INT              NULL,
    [SourceControlID]       INT              NULL,
    [SourceControlValue]    VARCHAR (255)    NULL,
    [Type]                  VARCHAR (50)     NULL,
    [RowsSummarized]        INT              NULL,
    CONSTRAINT [PK_SummaryExecutionLog] PRIMARY KEY CLUSTERED ([SummaryExecutionLogID] ASC)
);









