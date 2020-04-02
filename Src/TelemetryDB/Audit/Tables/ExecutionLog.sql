CREATE TABLE [Audit].[ExecutionLog] (
    [ExecutionLogId] INT              IDENTITY (1, 1) NOT NULL,
    [BatchId]        INT              NULL,
    [ActivityName]   VARCHAR (100)    NULL,
    [Message]        VARCHAR (MAX)    NULL,
    [LogDateTime]    DATETIME         DEFAULT (getdate()) NULL,
    [ADFRunId]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ExecutionLog] PRIMARY KEY CLUSTERED ([ExecutionLogId] ASC),
    CONSTRAINT [FK_ExecutionLog_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

