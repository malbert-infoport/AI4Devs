CREATE TABLE [Helix6_Test].[Course] (
    [Id]                    INT           IDENTITY (1, 1) NOT NULL,
    [Name]                  VARCHAR (200) NOT NULL,
    [VersionKey]            VARCHAR (100) NOT NULL,
    [VersionNumber]         INT           NOT NULL,
    [ValidityFrom]          DATETIME      NOT NULL,
    [ValidityTo]            DATETIME      NULL,
    [AuditCreationUser]     VARCHAR (70)  NULL,
    [AuditModificationUser] VARCHAR (70)  NULL,
    [AuditCreationDate]     DATETIME      NULL,
    [AuditModificationDate] DATETIME      NULL,
    [AuditDeletionDate]     DATETIME      NULL,
    CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Test', @level1type = N'TABLE', @level1name = N'Course', @level2type = N'COLUMN', @level2name = N'Id';

