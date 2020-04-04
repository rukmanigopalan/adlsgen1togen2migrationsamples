CREATE TABLE [Batch].[BatchMain] (
    [BatchId]         INT      IDENTITY (1, 1) NOT NULL,
    [BatchStartTime]  DATETIME NULL,
    [BatchEndTime]    DATETIME NULL,
    [BatchStatusId]   INT      NULL,
    [RowInsertedDate] DATETIME DEFAULT (getdate()) NULL,
    [RowUpdatedDate]  DATETIME NULL,
    CONSTRAINT [PK_BatchMain] PRIMARY KEY CLUSTERED ([BatchId] ASC),
    CONSTRAINT [FK_BatchMain_BatchStatusId] FOREIGN KEY ([BatchStatusId]) REFERENCES [Batch].[BatchStatus] ([BatchStatusId])
);

