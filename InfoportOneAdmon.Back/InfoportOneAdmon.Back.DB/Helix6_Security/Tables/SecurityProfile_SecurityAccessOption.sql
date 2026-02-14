CREATE TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] (
    [Id]                     INT          IDENTITY (1, 1) NOT NULL,
    [SecurityProfileId]      INT          NOT NULL,
    [SecurityAccessOptionId] INT          NOT NULL,
    [AuditCreationUser]      VARCHAR (70) NULL,
    [AuditModificationUser]  VARCHAR (70) NULL,
    [AuditCreationDate]      DATETIME     NULL,
    [AuditModificationDate]  DATETIME     NULL,
    [AuditDeletionDate]      DATETIME     NULL,
    CONSTRAINT [PK_SecurityProfile_SecurityAccessOption] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption] FOREIGN KEY ([SecurityAccessOptionId]) REFERENCES [Helix6_Security].[SecurityAccessOption] ([Id]),
    CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile] FOREIGN KEY ([SecurityProfileId]) REFERENCES [Helix6_Security].[SecurityProfile] ([Id]),
    CONSTRAINT [UK_SecurityProfile_SecurityAccessOption] UNIQUE NONCLUSTERED ([SecurityAccessOptionId] ASC, [SecurityProfileId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Opción de Acceso#Opción de acceso accesible para el perfil indicado', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'SecurityAccessOptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Perfil#Perfil con permiso de acceso a la opción de acceso indicada', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'SecurityProfileId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Accesos#Permisos de acceso para un determinado perfil de seguridad y las distintas opciones de acceso##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile_SecurityAccessOption';

