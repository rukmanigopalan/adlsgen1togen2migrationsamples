CREATE TABLE [Adf].[Datasets] (
    [DsId]                    INT            IDENTITY (1, 1) NOT NULL,
    [Name]                    NVARCHAR (500) NOT NULL,
    [Overwrite]               NVARCHAR (500) NOT NULL,
    [LsId]                    INT            NOT NULL,
    [PropertiesLocationType]  NVARCHAR (500) NOT NULL,
    [PropertiesFolderPath]    NVARCHAR (MAX) NOT NULL,
    [PropertiesContainerName] NVARCHAR (500) NOT NULL,
    [CreatedDate]             DATETIME       NULL
);

