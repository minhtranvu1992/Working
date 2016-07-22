CREATE TABLE [dbo].[DeliveryExecutionLog] (
    [DeliveryExecutionLog]       INT              IDENTITY (1, 1) NOT NULL,
    [DeliveryControlID]          INT              NOT NULL,
    [DeliveryJobID]              INT              NOT NULL,
    [ExtractJobID]               INT              NOT NULL,
    [StartTime]                  DATETIME         NOT NULL,
    [EndTime]                    DATETIME         NOT NULL,
    [ManagerGUID]                UNIQUEIDENTIFIER NULL,
    [SuccessFlag]                INT              NOT NULL,
    [CompletedFlag]              INT              NOT NULL,
    [MessageSource]              VARCHAR (1000)   NULL,
    [Message]                    VARCHAR (1000)   NULL,
    [RowsDelivered]              INT              NULL,
    [RowsErrored]                INT              NULL,
    [DeliveryPackageName]        VARCHAR (100)    NULL,
    [DeliveryPackagePath]        VARCHAR (100)    NULL,
    [DeliveryPackagePathAndName] VARCHAR (250)    NULL,
    [ScheduleType]               VARCHAR (50)     NULL,
    [ExecutionOrder]             INT              NULL,
    [LastExecutionTime]          DATETIME         NULL,
    [NextLastExecutionTime]      DATETIME         NOT NULL,
    CONSTRAINT [PK_DeliveryExecutionLog_1] PRIMARY KEY CLUSTERED ([DeliveryExecutionLog] ASC)
);





