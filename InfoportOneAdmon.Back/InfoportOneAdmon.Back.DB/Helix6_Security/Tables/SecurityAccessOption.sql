CREATE TABLE [Helix6_Security].[SecurityAccessOption] (
    [Id]                    INT           NOT NULL,
    [SecurityModuleId]      INT           NOT NULL,
    [Description]           VARCHAR (200) NOT NULL,
    [AuditCreationUser]     VARCHAR (70)  NULL,
    [AuditModificationUser] VARCHAR (70)  NULL,
    [AuditCreationDate]     DATETIME      NULL,
    [AuditModificationDate] DATETIME      NULL,
    [AuditDeletionDate]     DATETIME      NULL,
    CONSTRAINT [PK_SecurityAccessOption] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SecurityAccessOption_SecurityModule] FOREIGN KEY ([SecurityModuleId]) REFERENCES [Helix6_Security].[SecurityModule] ([Id]),
    CONSTRAINT [UK_SecurityAccessOption] UNIQUE NONCLUSTERED ([Description] ASC, [SecurityModuleId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Deletion Date#Logic registry deletion date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditDeletionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification Date#Last registry modification date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditModificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation Date#Registry creation date', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Modification User#Registry modification User', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditModificationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Audit - Creation User#Registry creation user', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'AuditCreationUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción#Descripcíon de la opción de acceso', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Módulo#Módulo al que pertenece la opción de acceso', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'SecurityModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID#Table identifier', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Opciones de Acceso#Opciones de acceso que determinan todos los puntos controlados por la seguridad del sistema, sobre los cuales se pueden dotar permisos de acceso##Seguridad', @level0type = N'SCHEMA', @level0name = N'Helix6_Security', @level1type = N'TABLE', @level1name = N'SecurityAccessOption';

