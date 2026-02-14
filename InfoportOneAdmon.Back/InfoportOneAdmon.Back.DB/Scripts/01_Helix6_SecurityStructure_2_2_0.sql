/*
Helix 6 - Security structure- 2.2.0
*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating schemas'
GO
CREATE SCHEMA [Helix6_Attachment]
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
CREATE SCHEMA [Helix6_Security]
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Attachment].[AttachmentFile]'
GO
CREATE TABLE [Helix6_Attachment].[AttachmentFile]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FileContent] [varchar] (max) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_AttachmentFile] on [Helix6_Attachment].[AttachmentFile]'
GO
ALTER TABLE [Helix6_Attachment].[AttachmentFile] ADD CONSTRAINT [PK_AttachmentFile] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Attachment].[Attachment]'
GO
CREATE TABLE [Helix6_Attachment].[Attachment]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EntityId] [int] NOT NULL,
[EntityName] [varchar] (1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
[EntityDescription] [varchar] (2000) COLLATE Modern_Spanish_CI_AS NOT NULL,
[FileName] [varchar] (1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
[FileExtension] [varchar] (10) COLLATE Modern_Spanish_CI_AS NULL,
[FileSizeKb] [int] NULL,
[AttachmentTypeId] [int] NULL,
[AttachmentDescription] [varchar] (2000) COLLATE Modern_Spanish_CI_AS NULL,
[AttachmentFileId] [int] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Attachment] on [Helix6_Attachment].[Attachment]'
GO
ALTER TABLE [Helix6_Attachment].[Attachment] ADD CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Attachment].[AttachmentType]'
GO
CREATE TABLE [Helix6_Attachment].[AttachmentType]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (2000) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_AttachmentType] on [Helix6_Attachment].[AttachmentType]'
GO
ALTER TABLE [Helix6_Attachment].[AttachmentType] ADD CONSTRAINT [PK_AttachmentType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityModule]'
GO
CREATE TABLE [Helix6_Security].[SecurityModule]
(
[Id] [int] NOT NULL,
[Description] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityModule] on [Helix6_Security].[SecurityModule]'
GO
ALTER TABLE [Helix6_Security].[SecurityModule] ADD CONSTRAINT [PK_SecurityModule] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityModule]'
GO
ALTER TABLE [Helix6_Security].[SecurityModule] ADD CONSTRAINT [UK_SecurityModule] UNIQUE NONCLUSTERED ([Description]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityAccessOption]'
GO
CREATE TABLE [Helix6_Security].[SecurityAccessOption]
(
[Id] [int] NOT NULL,
[SecurityModuleId] [int] NOT NULL,
[Description] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityAccessOption] on [Helix6_Security].[SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOption] ADD CONSTRAINT [PK_SecurityAccessOption] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOption] ADD CONSTRAINT [UK_SecurityAccessOption] UNIQUE NONCLUSTERED ([Description], [SecurityModuleId]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityAccessOptionLevel]'
GO
CREATE TABLE [Helix6_Security].[SecurityAccessOptionLevel]
(
[Id] [int] NOT NULL,
[SecurityAccessOptionId] [int] NOT NULL,
[Controller] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[SecurityLevel] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityAccessOptionLevel] on [Helix6_Security].[SecurityAccessOptionLevel]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] ADD CONSTRAINT [PK_SecurityAccessOptionLevel] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityAccessOptionLevel]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] ADD CONSTRAINT [UK_SecurityAccessOptionLevel] UNIQUE NONCLUSTERED ([SecurityAccessOptionId], [Controller]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityCompanyConfiguration]'
GO
CREATE TABLE [Helix6_Security].[SecurityCompanyConfiguration]
(
[Id] [int] NOT NULL,
[HostEmail] [nvarchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[PortEmail] [int] NULL,
[UserEmail] [nvarchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[PasswordEmail] [nvarchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[DefaultCredentialsEmail] [bit] NULL,
[SSLEmail] [bit] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityCompanyConfiguration] on [Helix6_Security].[SecurityCompanyConfiguration]'
GO
ALTER TABLE [Helix6_Security].[SecurityCompanyConfiguration] ADD CONSTRAINT [PK_SecurityCompanyConfiguration] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityCompany]'
GO
CREATE TABLE [Helix6_Security].[SecurityCompany]
(
[Id] [int] NOT NULL,
[SecurityCompanyGroupId] [int] NOT NULL,
[Name] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Cif] [varchar] (20) COLLATE Modern_Spanish_CI_AS NULL,
[SecurityCompanyConfigurationId] [int] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityCompany] on [Helix6_Security].[SecurityCompany]'
GO
ALTER TABLE [Helix6_Security].[SecurityCompany] ADD CONSTRAINT [PK_SecurityCompany] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityCompany]'
GO
ALTER TABLE [Helix6_Security].[SecurityCompany] ADD CONSTRAINT [UK_SecurityCompany] UNIQUE NONCLUSTERED ([SecurityCompanyGroupId], [Name]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityCompanyGroup]'
GO
CREATE TABLE [Helix6_Security].[SecurityCompanyGroup]
(
[Id] [int] NOT NULL,
[Name] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityCompanyGroup] on [Helix6_Security].[SecurityCompanyGroup]'
GO
ALTER TABLE [Helix6_Security].[SecurityCompanyGroup] ADD CONSTRAINT [PK_SecurityCompanyGroup] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [UK_SecurityCompanyGroup] on [Helix6_Security].[SecurityCompanyGroup]'
GO
CREATE NONCLUSTERED INDEX [UK_SecurityCompanyGroup] ON [Helix6_Security].[SecurityCompanyGroup] ([Name]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityProfile_SecurityAccessOption]'
GO
CREATE TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SecurityProfileId] [int] NOT NULL,
[SecurityAccessOptionId] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityProfile_SecurityAccessOption] on [Helix6_Security].[SecurityProfile_SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] ADD CONSTRAINT [PK_SecurityProfile_SecurityAccessOption] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityProfile_SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] ADD CONSTRAINT [UK_SecurityProfile_SecurityAccessOption] UNIQUE NONCLUSTERED ([SecurityAccessOptionId], [SecurityProfileId]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityProfile]'
GO
CREATE TABLE [Helix6_Security].[SecurityProfile]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SecurityCompanyId] [int] NOT NULL,
[Description] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Rol] [varchar] (100) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityProfile] on [Helix6_Security].[SecurityProfile]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile] ADD CONSTRAINT [PK_SecurityProfile] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityProfile]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile] ADD CONSTRAINT [UK_SecurityProfile] UNIQUE NONCLUSTERED ([Description], [SecurityCompanyId]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityUser]'
GO
CREATE TABLE [Helix6_Security].[SecurityUser]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SecurityCompanyId] [int] NOT NULL,
[UserIdentifier] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Login] [varchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[Name] [varchar] (200) COLLATE Modern_Spanish_CI_AS NULL,
[DisplayName] [varchar] (200) COLLATE Modern_Spanish_CI_AS NULL,
[Mail] [varchar] (200) COLLATE Modern_Spanish_CI_AS NULL,
[OrganizationCif] [varchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[OrganizationCode] [varchar] (50) COLLATE Modern_Spanish_CI_AS NULL,
[OrganizationName] [varchar] (200) COLLATE Modern_Spanish_CI_AS NULL,
[SecurityUserConfigurationId] [int] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityUser] on [Helix6_Security].[SecurityUser]'
GO
ALTER TABLE [Helix6_Security].[SecurityUser] ADD CONSTRAINT [PK_SecurityUser] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityUser]'
GO
ALTER TABLE [Helix6_Security].[SecurityUser] ADD CONSTRAINT [UK_SecurityUser] UNIQUE NONCLUSTERED ([SecurityCompanyId], [UserIdentifier]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityUserConfiguration]'
GO
CREATE TABLE [Helix6_Security].[SecurityUserConfiguration]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Pagination] [int] NOT NULL,
[ModalPagination] [int] NOT NULL,
[Language] [varchar] (10) COLLATE Modern_Spanish_CI_AS NOT NULL,
[LastConnectionDate] [datetime] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityUserConfiguration] on [Helix6_Security].[SecurityUserConfiguration]'
GO
ALTER TABLE [Helix6_Security].[SecurityUserConfiguration] ADD CONSTRAINT [PK_SecurityUserConfiguration] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityUserGridConfiguration]'
GO
CREATE TABLE [Helix6_Security].[SecurityUserGridConfiguration]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[SecurityUserId] [int] NOT NULL,
[Entity] [varchar] (100) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE Modern_Spanish_CI_AS NOT NULL,
[DefaultConfiguration] [bit] NOT NULL,
[Configuration] [varchar] (max) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityUserGridConfiguration] on [Helix6_Security].[SecurityUserGridConfiguration]'
GO
ALTER TABLE [Helix6_Security].[SecurityUserGridConfiguration] ADD CONSTRAINT [PK_SecurityUserGridConfiguration] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Security].[SecurityUserGridConfiguration]'
GO
ALTER TABLE [Helix6_Security].[SecurityUserGridConfiguration] ADD CONSTRAINT [UK_SecurityUserGridConfiguration] UNIQUE NONCLUSTERED ([SecurityUserId], [Entity], [Description]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Attachment].[VTA_Attachment]'
GO

CREATE VIEW [Helix6_Attachment].[VTA_Attachment]
AS
SELECT        A.Id, A.AttachmentTypeId, A.EntityId, A.EntityName, A.EntityDescription, A.FileName, A.FileExtension, A.FileSizeKb, A.AttachmentDescription, A.AttachmentFileId, A.AuditCreationUser, A.AuditModificationUser, A.AuditCreationDate, 
                         A.AuditModificationDate, A.AuditDeletionDate, AT.Description AS AttachmentType
FROM            Helix6_Attachment.Attachment AS A LEFT JOIN
                         Helix6_Attachment.AttachmentType AS AT ON A.AttachmentTypeId = AT.Id
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[Permissions]'
GO


CREATE VIEW [Helix6_Security].[Permissions]
AS
select CAST(ROW_NUMBER() OVER (ORDER BY AO.Id ASC) AS int) Id,
	   AO.Id as SecurityAccessOptionId, AO.[Description] as SecurityAccessOption, AOL.Controller, AOL.SecurityLevel, 
	   P.[Description] as Profile, P.Rol, M.[Description] as Module, C.Id as SecurityCompanyId, C.Name as SecurityCompany,
	   AO.AuditCreationUser, AO.AuditModificationUser, AO.AuditCreationDate, AO.AuditModificationDate, AO.AuditDeletionDate
from Helix6_Security.SecurityAccessOption AO
left join Helix6_Security.SecurityAccessOptionLevel AOL ON AOL.SecurityAccessOptionId = AO.Id
left join Helix6_Security.SecurityProfile_SecurityAccessOption PAO ON PAO.SecurityAccessOptionId = AO.Id 
left join Helix6_Security.SecurityProfile P ON PAO.SecurityProfileId = P.Id
left join Helix6_Security.SecurityModule M ON AO.SecurityModuleId = M.Id
left join Helix6_Security.SecurityCompany C ON P.SecurityCompanyId = C.Id
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Security].[SecurityVersion]'
GO
CREATE TABLE [Helix6_Security].[SecurityVersion]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Version] [nchar] (20) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Observations] [text] COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SecurityVersion] on [Helix6_Security].[SecurityVersion]'
GO
ALTER TABLE [Helix6_Security].[SecurityVersion] ADD CONSTRAINT [PK_SecurityVersion] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Attachment].[Attachment]'
GO
ALTER TABLE [Helix6_Attachment].[Attachment] ADD CONSTRAINT [FK_Attachment_AttachmentFile] FOREIGN KEY ([AttachmentFileId]) REFERENCES [Helix6_Attachment].[AttachmentFile] ([Id])
GO
ALTER TABLE [Helix6_Attachment].[Attachment] ADD CONSTRAINT [FK_Attachment_AttachmentType] FOREIGN KEY ([AttachmentTypeId]) REFERENCES [Helix6_Attachment].[AttachmentType] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityAccessOptionLevel]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] ADD CONSTRAINT [FK_SecurityAccessOptionLevel_SecurityAccessOption] FOREIGN KEY ([SecurityAccessOptionId]) REFERENCES [Helix6_Security].[SecurityAccessOption] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityAccessOption] ADD CONSTRAINT [FK_SecurityAccessOption_SecurityModule] FOREIGN KEY ([SecurityModuleId]) REFERENCES [Helix6_Security].[SecurityModule] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityCompany]'
GO
ALTER TABLE [Helix6_Security].[SecurityCompany] ADD CONSTRAINT [FK_SecurityCompany_SecurityCompanyConfiguration] FOREIGN KEY ([SecurityCompanyConfigurationId]) REFERENCES [Helix6_Security].[SecurityCompanyConfiguration] ([Id])
GO
ALTER TABLE [Helix6_Security].[SecurityCompany] ADD CONSTRAINT [FK_SecurityCompany_SecurityCompanyGroup] FOREIGN KEY ([SecurityCompanyGroupId]) REFERENCES [Helix6_Security].[SecurityCompanyGroup] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityProfile]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile] ADD CONSTRAINT [FK_SecurityProfile_SecurityCompany] FOREIGN KEY ([SecurityCompanyId]) REFERENCES [Helix6_Security].[SecurityCompany] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityProfile_SecurityAccessOption]'
GO
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] ADD CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption] FOREIGN KEY ([SecurityAccessOptionId]) REFERENCES [Helix6_Security].[SecurityAccessOption] ([Id])
GO
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] ADD CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile] FOREIGN KEY ([SecurityProfileId]) REFERENCES [Helix6_Security].[SecurityProfile] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityUserGridConfiguration]'
GO
ALTER TABLE [Helix6_Security].[SecurityUserGridConfiguration] ADD CONSTRAINT [FK_SecurityUserGridConfiguration_SecurityUser] FOREIGN KEY ([SecurityUserId]) REFERENCES [Helix6_Security].[SecurityUser] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Security].[SecurityUser]'
GO
ALTER TABLE [Helix6_Security].[SecurityUser] ADD CONSTRAINT [FK_SecurityUser_SecurityCompany] FOREIGN KEY ([SecurityCompanyId]) REFERENCES [Helix6_Security].[SecurityCompany] ([Id])
GO
ALTER TABLE [Helix6_Security].[SecurityUser] ADD CONSTRAINT [FK_SecurityUser_SecurityUserConfiguration] FOREIGN KEY ([SecurityUserConfigurationId]) REFERENCES [Helix6_Security].[SecurityUserConfiguration] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
