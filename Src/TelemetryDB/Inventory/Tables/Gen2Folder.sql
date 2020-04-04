CREATE TABLE [Inventory].[Gen2Folder] (
    [FolderId]             INT             IDENTITY (1, 1) NOT NULL,
    [BatchId]              INT             NULL,
    [ContainerName]        VARCHAR (100)   NULL,
    [FolderName]           NVARCHAR (100)  NULL,
    [FolderPath]           NVARCHAR (MAX)  NULL,
    [AssignedFolderType]   VARCHAR (50)    NULL,
    [IdentifiedFolderType] VARCHAR (50)    NULL,
    [FolderSizeInBytes]    DECIMAL (13, 2) NULL,
    [RowInsertedDate]      DATETIME        CONSTRAINT [DF__Gen2Folde__RowIn__3B40CD36] DEFAULT (getdate()) NULL,
    [RowUpdatedDate]       DATETIME        NULL,
    CONSTRAINT [PK_Gen2Folder] PRIMARY KEY CLUSTERED ([FolderId] ASC),
    CONSTRAINT [FK_Gen2Folder_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [Batch].[BatchMain] ([BatchId])
);

