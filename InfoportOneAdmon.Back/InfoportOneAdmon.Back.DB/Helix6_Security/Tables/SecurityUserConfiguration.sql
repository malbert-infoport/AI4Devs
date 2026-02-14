CREATE TABLE [Helix6_Security].[SecurityUserConfiguration] (
    [Id]                    INT          IDENTITY (1, 1) NOT NULL,
    [Pagination]            INT          NOT NULL,
    [ModalPagination]       INT          NOT NULL,
    [Language]              VARCHAR (10) NOT NULL,
    [LastConnectionDate]    DATETIME     NULL,
    [AuditCreationUser]     VARCHAR (70) NULL,
    [AuditModificationUser] VARCHAR (70) NULL,
    [AuditCreationDate]     DATETIME     NULL,
    [AuditModificationDate] DATETIME     NULL,
    [AuditDeletionDate]     DATETIME     NULL,
    CONSTRAINT [PK_SecurityUserConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Paginación Modal#Registros por página que se podrán visualizar para este usuario en las ventanas emergentes con listas de registros', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'ModalPagination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Paginación#Registros por página que se podrán visualizar para este usuario en las ventanas con listas de registros', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'Pagination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Personalización de Usuario#Parámetros de configuración asociados al usuario que determinan temas como la paginación o el idioma de la aplicación.##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityUserConfiguration', @level2type = N'COLUMN', @level2name = N'LastConnectionDate';

