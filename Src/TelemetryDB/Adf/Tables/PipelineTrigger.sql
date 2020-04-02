CREATE TABLE [Adf].[PipelineTrigger] (
    [TId]         INT            IDENTITY (1, 1) NOT NULL,
    [PId]         INT            NOT NULL,
    [Name]        NVARCHAR (500) NOT NULL,
    [Interval]    INT            NOT NULL,
    [Frequency]   NVARCHAR (100) NOT NULL,
    [CreatedDate] DATETIME       NULL
);

