CREATE TABLE [Helix6_Security].[SecurityCompany] (
    [Id]                             INT           NOT NULL,
    [SecurityCompanyGroupId]         INT           NOT NULL,
    [Name]                           VARCHAR (200) NOT NULL,
    [Cif]                            VARCHAR (20)  NULL,
    [SecurityCompanyConfigurationId] INT           NULL,
    [AuditCreationUser]              VARCHAR (70)  NULL,
    [AuditModificationUser]          VARCHAR (70)  NULL,
    [AuditCreationDate]              DATETIME      NULL,
    [AuditModificationDate]          DATETIME      NULL,
    [AuditDeletionDate]              DATETIME      NULL,
    CONSTRAINT [PK_SecurityCompany] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SecurityCompany_SecurityCompanyConfiguration] FOREIGN KEY ([SecurityCompanyConfigurationId]) REFERENCES [Helix6_Security].[SecurityCompanyConfiguration] ([Id]),
    CONSTRAINT [FK_SecurityCompany_SecurityCompanyGroup] FOREIGN KEY ([SecurityCompanyGroupId]) REFERENCES [Helix6_Security].[SecurityCompanyGroup] ([Id]),
    CONSTRAINT [UK_SecurityCompany] UNIQUE NONCLUSTERED ([SecurityCompanyGroupId] ASC, [Name] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Configuración#Configuración general de la aplicación asociada a la empresa de seguridad que para cada aplicación tiene unos campos distintos', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'SecurityCompanyConfigurationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cif#Cif de la empresa de seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'Cif';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre#Nombre de la empresa de seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompany';

