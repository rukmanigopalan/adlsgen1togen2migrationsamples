CREATE TABLE [Batch].[Config] (
    [ConfigId]        INT            IDENTITY (1, 1) NOT NULL,
    [Gen1AccountName] VARCHAR (100)  NULL,
    [Gen2AccountName] VARCHAR (100)  NULL,
    [Gen1RootPath]    NVARCHAR (500) NULL,
    [Gen2RootPath]    NVARCHAR (500) NULL,
    [IsChurned]       INT            NULL,
    [RowInsertedDate] DATETIME       DEFAULT (getdate()) NULL,
    [RowUpdatedDate]  DATETIME       NULL,
    CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED ([ConfigId] ASC)
);

