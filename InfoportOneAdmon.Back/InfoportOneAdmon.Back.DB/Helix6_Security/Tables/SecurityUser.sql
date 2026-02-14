CREATE TABLE [Helix6_Security].[SecurityUser] (
    [Id]                          INT           IDENTITY (1, 1) NOT NULL,
    [SecurityCompanyId]           INT           NOT NULL,
    [UserIdentifier]              VARCHAR (200) NOT NULL,
    [Login]                       VARCHAR (50)  NULL,
    [Name]                        VARCHAR (200) NULL,
    [DisplayName]                 VARCHAR (200) NULL,
    [Mail]                        VARCHAR (200) NULL,
    [OrganizationCif]             VARCHAR (50)  NULL,
    [OrganizationCode]            VARCHAR (50)  NULL,
    [OrganizationName]            VARCHAR (200) NULL,
    [SecurityUserConfigurationId] INT           NULL,
    [AuditCreationUser]           VARCHAR (70)  NULL,
    [AuditModificationUser]       VARCHAR (70)  NULL,
    [AuditCreationDate]           DATETIME      NULL,
    [AuditModificationDate]       DATETIME      NULL,
    [AuditDeletionDate]           DATETIME      NULL,
    CONSTRAINT [PK_SecurityUser] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SecurityUser_SecurityCompany] FOREIGN KEY ([SecurityCompanyId]) REFERENCES [Helix6_Security].[SecurityCompany] ([Id]),
    CONSTRAINT [FK_SecurityUser_SecurityUserConfiguration] FOREIGN KEY ([SecurityUserConfigurationId]) REFERENCES [Helix6_Security].[SecurityUserConfiguration] ([Id]),
    CONSTRAINT [UK_SecurityUser] UNIQUE NONCLUSTERED ([SecurityCompanyId] ASC, [UserIdentifier] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Configuración Usuario#Configuración específica del usuario logueado para esta aplicación ', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'SecurityUserConfigurationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mail#Mail del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'Mail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Login#Login de acceso del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'Login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificado de Usuario#Identificador del usuario procedente del gestor de identidades ', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'UserIdentifier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Empresa Seguridad#Empresa del entorno multiempresa de la aplicación a la que pertenece esta entidad.', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'SecurityCompanyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuarios#Usuarios pertenecientes a una empresa de seguridad##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'OrganizationName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'OrganizationCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'OrganizationCif';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre del usuario', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUser', @level2type = N'COLUMN', @level2name = N'DisplayName';

