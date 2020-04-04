CREATE TABLE [Audit].[FileACLComparison] (
    [BatchId]            INT              NULL,
    [Gen1FileName]       NVARCHAR (500)   NULL,
    [Gen2FileName]       NVARCHAR (500)   NULL,
    [Gen1FilePath]       NVARCHAR (500)   NULL,
    [Gen2FilePath]       NVARCHAR (500)   NULL,
    [Gen1AccessType]     VARCHAR (100)    NULL,
    [Gen2AccessType]     VARCHAR (100)    NULL,
    [Gen1AccessObjectId] UNIQUEIDENTIFIER NULL,
    [Gen2AccessObjectId] UNIQUEIDENTIFIER NULL,
    [Gen1FilePermission] VARCHAR (500)    NULL,
    [Gen2FilePermission] VARCHAR (500)    NULL,
    [IsMatching]         INT              NULL,
    [RowInsertedDate]    DATETIME         DEFAULT (getdate()) NULL,
    [RowModifiedDate]    DATETIME         NULL,
    CONSTRAINT [FK_FileACLComparison_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

