CREATE TABLE [dbo].[DateFormatType] (
    [DateFormatTypeID] INT           NOT NULL,
    [DateFormatString] VARCHAR (100) NOT NULL,
    [CreatedBy]        VARCHAR (100) CONSTRAINT [DF__DateForma__Creat__11D4A34F] DEFAULT (suser_name()) NULL,
    [CreatedDateTime]  DATETIME      CONSTRAINT [DF__DateForma__Creat__12C8C788] DEFAULT (getdate()) NULL,
    [UpdatedBy]        VARCHAR (100) CONSTRAINT [DF__DateForma__Updat__13BCEBC1] DEFAULT (suser_name()) NULL,
    [UpdatedDateTime]  DATETIME      CONSTRAINT [DF__DateForma__Updat__14B10FFA] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_DateFormatTYPE] PRIMARY KEY CLUSTERED ([DateFormatTypeID] ASC)
);



