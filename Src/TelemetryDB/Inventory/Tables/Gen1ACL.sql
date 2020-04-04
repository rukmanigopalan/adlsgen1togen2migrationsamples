CREATE TABLE [Inventory].[Gen1ACL] (
    [FileId]          INT              NULL,
    [FileName]        NVARCHAR (MAX)   NULL,
    [FilePath]        NVARCHAR (MAX)   NULL,
    [AccessScope]     VARCHAR (100)    NULL,
    [AccessType]      VARCHAR (100)    NULL,
    [AccessObjectId]  UNIQUEIDENTIFIER NULL,
    [FilePermission]  VARCHAR (100)    NULL,
    [RowInsertedDate] DATETIME         DEFAULT (getdate()) NULL,
    [RowUpdatedDate]  DATETIME         NULL,
    CONSTRAINT [FK_Gen1ACL_AccessObjectId] FOREIGN KEY ([AccessObjectId]) REFERENCES [Inventory].[ObjectMapping] ([AccessObjectId]),
    CONSTRAINT [FK_Gen1ACL_FileId] FOREIGN KEY ([FileId]) REFERENCES [Inventory].[Gen1File] ([FileId])
);

