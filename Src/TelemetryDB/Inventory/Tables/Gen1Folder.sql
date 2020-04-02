CREATE TABLE [Inventory].[Gen1Folder] (
    [FolderId]             INT             IDENTITY (1, 1) NOT NULL,
    [BatchId]              INT             NULL,
    [FolderName]           NVARCHAR (100)  NULL,
    [FolderPath]           NVARCHAR (MAX)  NULL,
    [AssignedFolderType]   VARCHAR (50)    NULL,
    [IdentifiedFolderType] VARCHAR (50)    NULL,
    [FolderSizeInBytes]    DECIMAL (13, 2) NULL,
    [RowInsertedDate]      DATETIME        DEFAULT (getdate()) NULL,
    [RowUpdatedDate]       DATETIME        NULL,
    CONSTRAINT [PK_Gen1Folder] PRIMARY KEY CLUSTERED ([FolderId] ASC),
    CONSTRAINT [FK_Gen1Folder_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

