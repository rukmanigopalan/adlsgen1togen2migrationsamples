CREATE TABLE [Inventory].[Gen2File] (
    [FileId]               INT              IDENTITY (1, 1) NOT NULL,
    [FileName]             NVARCHAR (MAX)   NULL,
    [FilePath]             NVARCHAR (MAX)   NULL,
    [FileBlobType]         VARCHAR (100)    NULL,
    [IsDeleted]            VARCHAR (10)     NULL,
    [ContentType]          VARCHAR (MAX)    NULL,
    [AccessTier]           VARCHAR (100)    NULL,
    [BlockSize]            INT              NULL,
    [FileSizeInBytes]      DECIMAL (13, 2)  NULL,
    [FileSizeInKB]         DECIMAL (13, 2)  NULL,
    [FileSizeInMB]         DECIMAL (13, 2)  NULL,
    [FileSizeInGB]         DECIMAL (13, 2)  NULL,
    [FileModificationTime] DATETIME         NULL,
    [FileOwner]            UNIQUEIDENTIFIER NULL,
    [RowInsertedDate]      DATETIME         DEFAULT (getdate()) NULL,
    [RowUpdatedDate]       DATETIME         NULL,
    [FolderId]             INT              NULL,
    CONSTRAINT [PK_Gen2File] PRIMARY KEY CLUSTERED ([FileId] ASC),
    CONSTRAINT [FK_Gen2File_FolderId] FOREIGN KEY ([FolderId]) REFERENCES [Inventory].[Gen2Folder] ([FolderId])
);

