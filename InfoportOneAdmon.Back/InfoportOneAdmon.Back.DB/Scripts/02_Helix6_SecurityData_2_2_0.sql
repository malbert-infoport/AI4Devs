/*
Helix 6 - Security data - 2.2.0
*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION

PRINT(N'Drop constraints from [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption]
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityUser]')
ALTER TABLE [Helix6_Security].[SecurityUser] NOCHECK CONSTRAINT [FK_SecurityUser_SecurityCompany]
ALTER TABLE [Helix6_Security].[SecurityUser] NOCHECK CONSTRAINT [FK_SecurityUser_SecurityUserConfiguration]

PRINT(N'Drop constraint FK_SecurityUserGridConfiguration_SecurityUser from [Helix6_Security].[SecurityUserGridConfiguration]')
ALTER TABLE [Helix6_Security].[SecurityUserGridConfiguration] NOCHECK CONSTRAINT [FK_SecurityUserGridConfiguration_SecurityUser]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityProfile]')
ALTER TABLE [Helix6_Security].[SecurityProfile] NOCHECK CONSTRAINT [FK_SecurityProfile_SecurityCompany]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityAccessOptionLevel]')
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] NOCHECK CONSTRAINT [FK_SecurityAccessOptionLevel_SecurityAccessOption]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityCompany]')
ALTER TABLE [Helix6_Security].[SecurityCompany] NOCHECK CONSTRAINT [FK_SecurityCompany_SecurityCompanyConfiguration]
ALTER TABLE [Helix6_Security].[SecurityCompany] NOCHECK CONSTRAINT [FK_SecurityCompany_SecurityCompanyGroup]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityAccessOption_SecurityModule]

PRINT(N'Drop constraint FK_Attachment_AttachmentType from [Helix6_Attachment].[Attachment]')
ALTER TABLE [Helix6_Attachment].[Attachment] NOCHECK CONSTRAINT [FK_Attachment_AttachmentType]

PRINT(N'Add rows to [Helix6_Attachment].[AttachmentType]')
SET IDENTITY_INSERT [Helix6_Attachment].[AttachmentType] ON
INSERT INTO [Helix6_Attachment].[AttachmentType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, N'General', N'1#admin', N'1#hlxusr', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Attachment].[AttachmentType] WHERE Id = 1)
INSERT INTO [Helix6_Attachment].[AttachmentType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, N'Worker Photo', N'1#admin', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Attachment].[AttachmentType] WHERE Id = 2)
SET IDENTITY_INSERT [Helix6_Attachment].[AttachmentType] OFF
PRINT(N'Operation applied to 2 rows out of 2')

PRINT(N'Add rows to [Helix6_Security].[SecurityCompanyConfiguration]')
INSERT INTO [Helix6_Security].[SecurityCompanyConfiguration] ([Id], [HostEmail], [PortEmail], [UserEmail], [PasswordEmail], [DefaultCredentialsEmail], [SSLEmail], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, NULL, NULL, NULL, NULL, NULL, NULL, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityCompanyConfiguration] WHERE Id = 1)
PRINT(N'Operation applied to 1 rows out of 2')

PRINT(N'Add row to [Helix6_Security].[SecurityCompanyGroup]')
INSERT INTO [Helix6_Security].[SecurityCompanyGroup] ([Id], [Name], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, N'CompanyGroup', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityCompanyGroup] WHERE Id = 1)

PRINT(N'Add rows to [Helix6_Security].[SecurityModule]')
INSERT INTO [Helix6_Security].[SecurityModule] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, N'Security', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityModule] WHERE Id = 1)
INSERT INTO [Helix6_Security].[SecurityModule] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, N'Attachments', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityModule] WHERE Id = 2)
INSERT INTO [Helix6_Security].[SecurityModule] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 3, N'Masters', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityModule] WHERE Id = 3)
PRINT(N'Operation applied to 3 rows out of 4')

PRINT(N'Add rows to [Helix6_Security].[SecurityAccessOption]')
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 1, N'User customization', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 1)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 1, N'Profile query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 2)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 3, 1, N'Profile modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 3)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 4, 1, N'General company configuration query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 4)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 5, 1, N'General company configuration modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 5)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 6, 2, N'Attachment query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 6)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 7, 2, N'Attachment modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 7)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 8, 2, N'View or download attachments', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 8)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 9, 2, N'Attachment masters query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 9)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 10, 2, N'Attachment masters modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 10)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 13, 3, N'Masters access', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOption]  WHERE Id = 13)
PRINT(N'Operation applied to 11 rows out of 15')

PRINT(N'Add rows to [Helix6_Security].[SecurityCompany]')
INSERT INTO [Helix6_Security].[SecurityCompany] ([Id], [SecurityCompanyGroupId], [Name], [Cif], [SecurityCompanyConfigurationId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 1, N'SecurityCompany', N'12345678Z2', 1, N'1#hlxadm', N'1#hlxusr', GETDATE(), '2023-08-03 07:31:29.110', NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityCompany]  WHERE Id = 1)
PRINT(N'Operation applied to 1 rows out of 2')

PRINT(N'Add rows to [Helix6_Security].[SecurityAccessOptionLevel]')
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 1, N'SecurityUserConfiguration', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 1)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 1, N'SecurityUserGridConfiguration', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 2)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 3, 1, N'SecurityVersion', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 3)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 4, 2, N'SecurityProfile', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 4)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 5, 3, N'SecurityProfile', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 5)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 6, 2, N'SecurityModule', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 6)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 7, 3, N'SecurityModule', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 7)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 8, 4, N'SecurityCompany', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 8)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 9, 5, N'SecurityCompany', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 9)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 10, 6, N'VTA_Attachment', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 10)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 11, 7, N'VTA_Attachment', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 11)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 12, 6, N'Attachment', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 12)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 13, 7, N'Attachment', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 13)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 14, 6, N'AttachmentType', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 14)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 15, 10, N'AttachmentType', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 15)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 16, 9, N'AttachmentType', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityAccessOptionLevel] WHERE Id = 16)
PRINT(N'Operation applied to 16 rows out of 28')

PRINT(N'Add rows to [Helix6_Security].[SecurityProfile]')
SET IDENTITY_INSERT [Helix6_Security].[SecurityProfile] ON
INSERT INTO [Helix6_Security].[SecurityProfile] ([Id], [SecurityCompanyId], [Description], [Rol], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 1, N'Admin55', N'HLX_admin', NULL, N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile] WHERE Id = 1)
INSERT INTO [Helix6_Security].[SecurityProfile] ([Id], [SecurityCompanyId], [Description], [Rol], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 1, N'Prueba', N'HLX_user', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile] WHERE Id = 2)
SET IDENTITY_INSERT [Helix6_Security].[SecurityProfile] OFF
PRINT(N'Operation applied to 2 rows out of 2')

--PRINT(N'Add rows to [Helix6_Security].[SecurityUser]')
--SET IDENTITY_INSERT [Helix6_Security].[SecurityUser] ON
--INSERT INTO [Helix6_Security].[SecurityUser] ([Id], [SecurityCompanyId], [UserIdentifier], [Login], [Name], [DisplayName], [Mail], [OrganizationCif], [OrganizationCode], [OrganizationName], [SecurityUserConfigurationId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 1, N'1cf9c7c8-db4b-411d-ab63-cda088d355bd', N'hlxadm', N'Antonio', N'Antonio Fernández Solana', N'antoniofernandez@helix6.es', N'87654321R', N'0043', N'Consignataria La Torre', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
--WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityUser]] WHERE Id = 2)
--INSERT INTO [Helix6_Security].[SecurityUser] ([Id], [SecurityCompanyId], [UserIdentifier], [Login], [Name], [DisplayName], [Mail], [OrganizationCif], [OrganizationCode], [OrganizationName], [SecurityUserConfigurationId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 3, 1, N'b27e3219-a1cc-4251-a277-859518fb8d1c', N'hlxusr', N'Pedro', N'Pedro Moreno Badía', N'pedromoreno@helix6.es', N'87654321R', N'0043', N'Consignataria La Torre', 3, N'1#hlxadm', N'1#hlxusr', GETDATE(), GETDATE(), NULL
--WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityUser]] WHERE Id = 3)
--INSERT INTO [Helix6_Security].[SecurityUser] ([Id], [SecurityCompanyId], [UserIdentifier], [Login], [Name], [DisplayName], [Mail], [OrganizationCif], [OrganizationCode], [OrganizationName], [SecurityUserConfigurationId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 4, 1, N'113b30f9-aea5-4e37-8a9a-8054b062eca9', N'hlxadm', N'hlxadm', N'Display Name Admin', N'admin@email.com', N'B123456789', N'0001', N'Organización', 4, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
--WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityUser]] WHERE Id = 4)
--SET IDENTITY_INSERT [Helix6_Security].[SecurityUser] OFF
--PRINT(N'Operation applied to 3 rows out of 3')

PRINT(N'Add rows to [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 1)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 3, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 3)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 5, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 5)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 7, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 7)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 1)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 6, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 6)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 7, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 7)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 13, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 13)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 2)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 4, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 4)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 6, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 6)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 8, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 8)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 9, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 9)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 10, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 10)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 1, 13, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 1 AND SecurityAccessOptionId = 13)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 8, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 8)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 9, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 9)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 10, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 10)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 2)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 3, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 3)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 4, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 4)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, 5, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Security].[SecurityProfile_SecurityAccessOption] WHERE SecurityProfileId = 2 AND SecurityAccessOptionId = 5)
PRINT(N'Operation applied to 22 rows out of 29')

PRINT(N'Add constraints to [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption]
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile]

PRINT(N'Add constraints to [Helix6_Security].[SecurityUser]')
ALTER TABLE [Helix6_Security].[SecurityUser] WITH CHECK CHECK CONSTRAINT [FK_SecurityUser_SecurityCompany]
ALTER TABLE [Helix6_Security].[SecurityUser] WITH CHECK CHECK CONSTRAINT [FK_SecurityUser_SecurityUserConfiguration]
ALTER TABLE [Helix6_Security].[SecurityUserGridConfiguration] WITH CHECK CHECK CONSTRAINT [FK_SecurityUserGridConfiguration_SecurityUser]

PRINT(N'Add constraints to [Helix6_Security].[SecurityProfile]')
ALTER TABLE [Helix6_Security].[SecurityProfile] WITH CHECK CHECK CONSTRAINT [FK_SecurityProfile_SecurityCompany]

PRINT(N'Add constraints to [Helix6_Security].[SecurityAccessOptionLevel]')
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] WITH CHECK CHECK CONSTRAINT [FK_SecurityAccessOptionLevel_SecurityAccessOption]

PRINT(N'Add constraints to [Helix6_Security].[SecurityCompany]')
ALTER TABLE [Helix6_Security].[SecurityCompany] WITH CHECK CHECK CONSTRAINT [FK_SecurityCompany_SecurityCompanyConfiguration]
ALTER TABLE [Helix6_Security].[SecurityCompany] WITH CHECK CHECK CONSTRAINT [FK_SecurityCompany_SecurityCompanyGroup]

PRINT(N'Add constraints to [Helix6_Security].[SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityAccessOption_SecurityModule]
ALTER TABLE [Helix6_Attachment].[Attachment] WITH CHECK CHECK CONSTRAINT [FK_Attachment_AttachmentType]
COMMIT TRANSACTION
GO

PRINT(N'Reseed identity on [Helix6_Security].[SecurityProfile]')
DBCC CHECKIDENT(N'[Helix6_Security].[SecurityProfile]', RESEED, 2)
DBCC CHECKIDENT(N'[Helix6_Security].[SecurityProfile]', RESEED)
GO

PRINT(N'Reseed identity on [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
DBCC CHECKIDENT(N'[Helix6_Security].[SecurityProfile_SecurityAccessOption]', RESEED, 22)
DBCC CHECKIDENT(N'[Helix6_Security].[SecurityProfile_SecurityAccessOption]', RESEED)
GO
