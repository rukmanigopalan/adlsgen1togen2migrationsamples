CREATE TABLE [Batch].[BatchStatus] (
    [BatchStatusId] INT           NOT NULL,
    [StatusName]    VARCHAR (100) NULL,
    CONSTRAINT [PK_BatchStatus] PRIMARY KEY CLUSTERED ([BatchStatusId] ASC)
);

