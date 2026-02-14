CREATE TABLE [Helix6_Security].[SecurityCompanyConfiguration] (
    [Id]                      INT           NOT NULL,
    [HostEmail]               NVARCHAR (50) NULL,
    [PortEmail]               INT           NULL,
    [UserEmail]               NVARCHAR (50) NULL,
    [PasswordEmail]           NVARCHAR (50) NULL,
    [DefaultCredentialsEmail] BIT           NULL,
    [SSLEmail]                BIT           NULL,
    [AuditCreationUser]       VARCHAR (70)  NULL,
    [AuditModificationUser]   VARCHAR (70)  NULL,
    [AuditCreationDate]       DATETIME      NULL,
    [AuditModificationDate]   DATETIME      NULL,
    [AuditDeletionDate]       DATETIME      NULL,
    CONSTRAINT [PK_SecurityCompanyConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Empresas Seguridad#En un entorno multiempresa esta tabla contiene la lista de empresas configuradas que podrán trabajar con la aplicación##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityCompanyConfiguration';

