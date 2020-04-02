CREATE TABLE [Inventory].[Gen1File] (
    [FileId]               INT              IDENTITY (1, 1) NOT NULL,
    [FolderId]             INT              NULL,
    [FileName]             NVARCHAR (MAX)   NULL,
    [FilePath]             NVARCHAR (MAX)   NULL,
    [BlockSize]            INT              NULL,
    [FileSizeInBytes]      DECIMAL (13, 2)  NULL,
    [FileModificationTime] DATETIME         NULL,
    [FileOwner]            UNIQUEIDENTIFIER NULL,
    [FileLastWriteTime]    DATETIME         NULL,
    [RowInsertedDate]      DATETIME         CONSTRAINT [DF__Gen1File__RowIns__31B762FC] DEFAULT (getdate()) NULL,
    [RowUpdatedDate]       DATETIME         NULL,
    CONSTRAINT [PK_Gen1File] PRIMARY KEY CLUSTERED ([FileId] ASC),
    CONSTRAINT [FK_Gen1File_FolderId] FOREIGN KEY ([FolderId]) REFERENCES [Inventory].[Gen1Folder] ([FolderId])
);

