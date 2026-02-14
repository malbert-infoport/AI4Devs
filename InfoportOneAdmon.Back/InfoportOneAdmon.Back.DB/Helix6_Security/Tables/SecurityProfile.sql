CREATE TABLE [Helix6_Security].[SecurityProfile] (
    [Id]                    INT           IDENTITY (1, 1) NOT NULL,
    [SecurityCompanyId]     INT           NOT NULL,
    [Description]           VARCHAR (200) NOT NULL,
    [Rol]                   VARCHAR (100) NULL,
    [AuditCreationUser]     VARCHAR (70)  NULL,
    [AuditModificationUser] VARCHAR (70)  NULL,
    [AuditCreationDate]     DATETIME      NULL,
    [AuditModificationDate] DATETIME      NULL,
    [AuditDeletionDate]     DATETIME      NULL,
    CONSTRAINT [PK_SecurityProfile] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SecurityProfile_SecurityCompany] FOREIGN KEY ([SecurityCompanyId]) REFERENCES [Helix6_Security].[SecurityCompany] ([Id]),
    CONSTRAINT [UK_SecurityProfile] UNIQUE NONCLUSTERED ([Description] ASC, [SecurityCompanyId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción#Descripción del perfil', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Empresa Seguridad#Empresa del entorno multiempresa de la aplicación a la que pertenece esta entidad.', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'SecurityCompanyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Perfiles de Seguridad#Perfiles a los que pertenecen los usuarios del sistema y que condiciona los permisos de los mismos##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityProfile';

