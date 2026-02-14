CREATE TABLE [Helix6_Attachment].[Attachment] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [EntityId]              INT            NOT NULL,
    [EntityName]            VARCHAR (1000) NOT NULL,
    [EntityDescription]     VARCHAR (2000) NOT NULL,
    [FileName]              VARCHAR (1000) NOT NULL,
    [FileExtension]         VARCHAR (10)   NULL,
    [FileSizeKb]            INT            NULL,
    [AttachmentTypeId]      INT            NULL,
    [AttachmentDescription] VARCHAR (2000) NULL,
    [AttachmentFileId]      INT            NULL,
    [AuditCreationUser]     VARCHAR (70)   NULL,
    [AuditModificationUser] VARCHAR (70)   NULL,
    [AuditCreationDate]     DATETIME       NULL,
    [AuditModificationDate] DATETIME       NULL,
    [AuditDeletionDate]     DATETIME       NULL,
    CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Attachment_AttachmentFile] FOREIGN KEY ([AttachmentFileId]) REFERENCES [Helix6_Attachment].[AttachmentFile] ([Id]),
    CONSTRAINT [FK_Attachment_AttachmentType] FOREIGN KEY ([AttachmentTypeId]) REFERENCES [Helix6_Attachment].[AttachmentType] ([Id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Attachment', @level1type = N'TABLE', @level1name = N'Attachment', @level2type = N'COLUMN', @level2name = N'Id';

