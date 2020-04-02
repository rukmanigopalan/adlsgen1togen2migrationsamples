CREATE TABLE [Adf].[Pipelines] (
    [PId]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (500) NOT NULL,
    [Overwrite]   NVARCHAR (500) NOT NULL,
    [Incremental] NVARCHAR (500) NOT NULL,
    [CreatedDate] DATETIME       NULL
);

