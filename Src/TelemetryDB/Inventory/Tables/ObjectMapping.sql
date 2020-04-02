CREATE TABLE [Inventory].[ObjectMapping] (
    [AccessObjectId] UNIQUEIDENTIFIER NOT NULL,
    [Name]           NVARCHAR (500)   NULL,
    CONSTRAINT [PK_ObjectMapping] PRIMARY KEY CLUSTERED ([AccessObjectId] ASC)
);

