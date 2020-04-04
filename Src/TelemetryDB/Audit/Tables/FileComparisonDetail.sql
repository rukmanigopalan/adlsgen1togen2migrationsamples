CREATE TABLE [Audit].[FileComparisonDetail] (
    [BatchId]                  INT             NULL,
    [Gen1FileName]             NVARCHAR (500)  NULL,
    [Gen2FileName]             NVARCHAR (500)  NULL,
    [Gen1FilePath]             NVARCHAR (500)  NULL,
    [Gen2FilePath]             NVARCHAR (500)  NULL,
    [Gen1FileSize]             DECIMAL (13, 2) NULL,
    [Gen2FileSize]             DECIMAL (13, 2) NULL,
    [Gen1FileModificationTime] DATETIME        NULL,
    [Gen2FileModificationTime] DATETIME        NULL,
    [IsMatching]               INT             NULL,
    [RowInsertedDate]          DATETIME        DEFAULT (getdate()) NULL,
    [RowModifiedDate]          DATETIME        NULL,
    CONSTRAINT [FK_FileComparisonDetail_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

