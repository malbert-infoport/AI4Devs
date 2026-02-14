CREATE TABLE [Helix6_Test].[Worker] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [Name]                  VARCHAR (500)  NOT NULL,
    [Surnames]              VARCHAR (200)  NOT NULL,
    [BirthDate]             DATETIME       NOT NULL,
    [IsTrainee]             BIT            NOT NULL,
    [WorkerTypeId]          INT            NOT NULL,
    [Age]                   INT            NULL,
    [Height]                DECIMAL (4, 2) NULL,
    [AuditCreationUser]     VARCHAR (70)   NULL,
    [AuditModificationUser] VARCHAR (70)   NULL,
    [AuditCreationDate]     DATETIME       NULL,
    [AuditModificationDate] DATETIME       NULL,
    [AuditDeletionDate]     DATETIME       NULL,
    CONSTRAINT [PK_Worker] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Worker_WorkerType] FOREIGN KEY ([WorkerTypeId]) REFERENCES [Helix6_Test].[WorkerType] ([Id]),
    CONSTRAINT [UK_Worker] UNIQUE NONCLUSTERED ([Name] ASC, [Surnames] ASC, [AuditDeletionDate] ASC)
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Worker', @level2type = N'COLUMN', @level2name = N'Id';

