CREATE TABLE [Adf].[LinkedServices] (
    [LsId]           INT            IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (500) NOT NULL,
    [Overwrite]      NVARCHAR (500) NOT NULL,
    [PropertiesType] NVARCHAR (500) NOT NULL,
    [PropertiesUri]  NVARCHAR (MAX) NOT NULL,
    [CreatedDate]    DATETIME       NULL
);

