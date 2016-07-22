CREATE TABLE [dbo].[ETLParameters] (
    [ETLParameterName]  VARCHAR (50) NOT NULL,
    [ETLParameterValue] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ETLParameters] PRIMARY KEY CLUSTERED ([ETLParameterName] ASC)
);

