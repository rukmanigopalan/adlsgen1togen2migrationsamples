CREATE TABLE [Inventory].[Gen1FolderTelemetry] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Message]         NVARCHAR (MAX) NULL,
    [RowInsertedDate] DATETIME       NULL,
    [RowUpdatedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

