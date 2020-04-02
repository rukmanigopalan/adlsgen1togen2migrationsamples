CREATE TABLE [Adf].[ActivitiesFull] (
    [AId]         INT            IDENTITY (1, 1) NOT NULL,
    [PId]         INT            NOT NULL,
    [Name]        NVARCHAR (500) NOT NULL,
    [InputDsId]   INT            NOT NULL,
    [OutputDsId]  INT            NOT NULL,
    [CreatedDate] DATETIME       NULL
);

