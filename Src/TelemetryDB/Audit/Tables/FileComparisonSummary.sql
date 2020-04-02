CREATE TABLE [Audit].[FileComparisonSummary] (
    [BatchId]            INT             NULL,
    [Gen1RootPath]       VARCHAR (500)   NULL,
    [Gen2RootPath]       VARCHAR (500)   NULL,
    [Gen1FilesCount]     BIGINT          NULL,
    [Gen2FilesCount]     BIGINT          NULL,
    [Gen1TotalFilesSize] DECIMAL (13, 2) NULL,
    [Gen2TotalFilesSize] DECIMAL (13, 2) NULL,
    [IsMatching]         INT             NULL,
    [RowInsertedDate]    DATETIME        DEFAULT (getdate()) NULL,
    [RowUpdatedDate]     DATETIME        NULL,
    CONSTRAINT [FK_FileComparisonSummary_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

