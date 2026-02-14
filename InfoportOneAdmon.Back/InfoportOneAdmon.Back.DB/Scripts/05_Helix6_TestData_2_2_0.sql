/*
Helix 6 - Test data - 2.2.0
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

PRINT(N'Drop constraints from [Helix6_Test].[WorkerAddress]')
ALTER TABLE [Helix6_Test].[WorkerAddress] NOCHECK CONSTRAINT [FK_WorkerAddress_AddressType]
ALTER TABLE [Helix6_Test].[WorkerAddress] NOCHECK CONSTRAINT [FK_WorkerAddress_Worker]

PRINT(N'Drop constraints from [Helix6_Test].[Worker_Project]')
ALTER TABLE [Helix6_Test].[Worker_Project] NOCHECK CONSTRAINT [FK_Worker_Project_Project]
ALTER TABLE [Helix6_Test].[Worker_Project] NOCHECK CONSTRAINT [FK_Worker_Project_Worker]

PRINT(N'Drop constraints from [Helix6_Test].[Worker_Course]')
ALTER TABLE [Helix6_Test].[Worker_Course] NOCHECK CONSTRAINT [FK_Worker_Course_Course]
ALTER TABLE [Helix6_Test].[Worker_Course] NOCHECK CONSTRAINT [FK_Worker_Course_Worker]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption]
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityAccessOptionLevel]')
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] NOCHECK CONSTRAINT [FK_SecurityAccessOptionLevel_SecurityAccessOption]

PRINT(N'Drop constraints from [Helix6_Test].[Worker]')
ALTER TABLE [Helix6_Test].[Worker] NOCHECK CONSTRAINT [FK_Worker_WorkerType]

PRINT(N'Drop constraints from [Helix6_Security].[SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityAccessOption] NOCHECK CONSTRAINT [FK_SecurityAccessOption_SecurityModule]

PRINT(N'Add row to [Helix6_Security].[SecurityModule]')
INSERT INTO [Helix6_Security].[SecurityModule] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (100, N'Workers', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)

PRINT(N'Add rows to [Helix6_Test].[AddressType]')
INSERT INTO [Helix6_Test].[AddressType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, N'Home', N'1#admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[AddressType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, N'Business', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[AddressType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, N'Billing', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
PRINT(N'Operation applied to 3 rows out of 3')

PRINT(N'Add rows to [Helix6_Test].[Course]')
SET IDENTITY_INSERT [Helix6_Test].[Course] ON
INSERT INTO [Helix6_Test].[Course] ([Id], [Name], [VersionKey], [VersionNumber], [ValidityFrom], [ValidityTo], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, N'Scrum 2023', N'Scrum', 2, '2022-12-31 23:00:00.000', NULL, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Course] ([Id], [Name], [VersionKey], [VersionNumber], [ValidityFrom], [ValidityTo], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, N'ITIL', N'ITIL', 1, '2023-01-02 23:00:00.000', NULL, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Course] ([Id], [Name], [VersionKey], [VersionNumber], [ValidityFrom], [ValidityTo], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, N'Azure', N'Azure', 1, '2023-01-04 23:00:00.000', NULL, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Course] ([Id], [Name], [VersionKey], [VersionNumber], [ValidityFrom], [ValidityTo], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (4, N'Scrum 2022', N'Scrum', 1, '2021-12-31 23:00:00.000', '2022-12-31 22:59:59.000', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
SET IDENTITY_INSERT [Helix6_Test].[Course] OFF
PRINT(N'Operation applied to 4 rows out of 4')

PRINT(N'Add rows to [Helix6_Test].[Project]')
SET IDENTITY_INSERT [Helix6_Test].[Project] ON
INSERT INTO [Helix6_Test].[Project] ([Id], [Name], [VersionKey], [VersionNumber], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, N'Dynamic Pro: Phase 1', N'Dynamic', 1, N'1#admin', N'1#admin', GETDATE(), GETDATE(), GETDATE())
INSERT INTO [Helix6_Test].[Project] ([Id], [Name], [VersionKey], [VersionNumber], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, N'Project Signal', N'Signal', 1, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Project] ([Id], [Name], [VersionKey], [VersionNumber], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, N'Capricorn', N'Capricorn', 1, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Project] ([Id], [Name], [VersionKey], [VersionNumber], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (4, N'Dynamic Pro: Phase 2', N'Dynamic', 2, N'1#admin', N'1#admin', GETDATE(), GETDATE(), GETDATE())
INSERT INTO [Helix6_Test].[Project] ([Id], [Name], [VersionKey], [VersionNumber], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (5, N'Dynamic Pro: Phase 3', N'Dynamic', 3, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
SET IDENTITY_INSERT [Helix6_Test].[Project] OFF
PRINT(N'Operation applied to 5 rows out of 5')

PRINT(N'Add rows to [Helix6_Test].[WorkerType]')
INSERT INTO [Helix6_Test].[WorkerType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, N'Fixed-term', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[WorkerType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, N'Seasonal', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[WorkerType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, N'Agency', N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
PRINT(N'Operation applied to 3 rows out of 3')

PRINT(N'Add rows to [Helix6_Security].[SecurityAccessOption]')
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (100, 100, N'Worker query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (101, 100, N'Worker modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (102, 100, N'Project query', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOption] ([Id], [SecurityModuleId], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (103, 100, N'Project modification', N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
PRINT(N'Operation applied to 4 rows out of 4')

PRINT(N'Add rows to [Helix6_Test].[Worker]')
SET IDENTITY_INSERT [Helix6_Test].[Worker] ON
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, N'Antonio', N'Sarabia Lozano', '1974-06-11 22:00:00.000', 1, 1, 49, 1.88, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, N'Pablo', N'Fernández García', '1991-02-03 23:00:00.000', 1, 1, 32, 1.72, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, N'Maria', N'Pérez Langa', '1992-12-19 23:00:00.000', 0, 1, 31, 1.62, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (4, N'Paula', N'Herranz Fortuny', '1984-07-14 22:00:00.000', 0, 2, 39, 1.66, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (5, N'Malena 3', N'Bonilla Planas', '1977-03-24 21:00:00.000', 0, 2, 46, 1.72, N'1#admin', N'1#hlxusr', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (6, N'Hector', N'Mulet Corbacho', '1988-05-27 22:00:00.000', 1, 3, 35, 1.90, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (7, N'Felix', N'Soler Jerez', '1991-04-03 22:00:00.000', 1, 3, NULL, NULL, N'1#admin', N'1#admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (8, N'Sofia', N'Arnau Bueno', '1994-03-02 23:00:00.000', 0, 3, NULL, NULL, N'1#admin', N'1#admin', GETDATE(), GETDATE(), GETDATE())
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (9, N'Salva', N'Bueno Navarro', '1990-01-10 23:00:00.000', 0, 1, 33, 1.98, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Test].[Worker] ([Id], [Name], [Surnames], [BirthDate], [IsTrainee], [WorkerTypeId], [Age], [Height], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (10, N'Ángeles', N'Bueno Navarro', '1990-01-10 23:00:00.000', 0, 1, 33, 1.98, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
SET IDENTITY_INSERT [Helix6_Test].[Worker] OFF
PRINT(N'Operation applied to 10 rows out of 10')

PRINT(N'Add rows to [Helix6_Security].[SecurityAccessOptionLevel]')
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (100, 100, N'Worker', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (101, 100, N'WorkerType', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (102, 101, N'Worker', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (104, 102, N'Project', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (105, 103, N'Project', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (106, 100, N'Prueba', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (107, 101, N'Prueba', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (108, 100, N'VistaPrueba', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (109, 100, N'AddressType', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (111, 101, N'WorkerAddress', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (112, 100, N'Course', 1, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityAccessOptionLevel] ([Id], [SecurityAccessOptionId], [Controller], [SecurityLevel], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (113, 101, N'Course', 2, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
PRINT(N'Operation applied to 12 rows out of 12')

PRINT(N'Add rows to [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
SET IDENTITY_INSERT [Helix6_Security].[SecurityProfile_SecurityAccessOption] ON
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (100, 1, 101, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (101, 1, 103, N'1#hlxadm', N'1#hlxadm', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1202, 2, 100, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1203, 2, 101, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1204, 2, 102, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1205, 2, 103, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
INSERT INTO [Helix6_Security].[SecurityProfile_SecurityAccessOption] ([Id], [SecurityProfileId], [SecurityAccessOptionId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1213, 1, 100, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', GETDATE(), GETDATE(), NULL)
SET IDENTITY_INSERT [Helix6_Security].[SecurityProfile_SecurityAccessOption] OFF
PRINT(N'Operation applied to 7 rows out of 7')

PRINT(N'Add rows to [Helix6_Test].[Worker_Course]')
SET IDENTITY_INSERT [Helix6_Test].[Worker_Course] ON
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (601, 1, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.830', '2023-07-25 07:15:20.830', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (602, 1, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.843', '2023-07-25 07:15:20.843', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (603, 1, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.843', '2023-07-25 07:15:20.843', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (604, 2, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (605, 3, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (606, 3, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (607, 3, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (608, 3, 4, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (611, 6, 4, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (612, 8, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (613, 8, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (614, 8, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
INSERT INTO [Helix6_Test].[Worker_Course] ([Id], [WorkerId], [CourseId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (615, 8, 4, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
SET IDENTITY_INSERT [Helix6_Test].[Worker_Course] OFF
PRINT(N'Operation applied to 13 rows out of 13')

PRINT(N'Add rows to [Helix6_Test].[Worker_Project]')
SET IDENTITY_INSERT [Helix6_Test].[Worker_Project] ON
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, 1, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.793', '2023-07-25 07:15:20.793', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, 1, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.813', '2023-07-25 07:15:20.813', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, 1, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.813', '2023-07-25 07:15:20.813', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (4, 2, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (5, 2, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (6, 3, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (7, 4, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (8, 5, 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (9, 5, 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (10, 6, 2, N'1#admin', N'1#admin', '2023-07-25 07:15:20.850', '2023-07-25 07:15:20.850', NULL)
INSERT INTO [Helix6_Test].[Worker_Project] ([Id], [WorkerId], [ProjectId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (11, 9, 2, N'1#Nombre completo del Admin', N'1#Nombre completo del Admin', '2023-08-30 09:08:00.263', '2023-08-30 09:08:00.263', NULL)
SET IDENTITY_INSERT [Helix6_Test].[Worker_Project] OFF
PRINT(N'Operation applied to 11 rows out of 11')

PRINT(N'Add rows to [Helix6_Test].[WorkerAddress]')
SET IDENTITY_INSERT [Helix6_Test].[WorkerAddress] ON
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (1, 1, N'C/La baranda, 1, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.813', '2023-07-25 07:15:20.813', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (2, 1, N'C/Sorni, 14, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.830', '2023-07-25 07:15:20.830', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (3, 1, N'C/La baranda, 1, Valencia', 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.830', '2023-07-25 07:15:20.830', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (4, 2, N'C/Lombarda, 17, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (5, 2, N'C/Sorni, 14, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (6, 2, N'C/Lombarda, 17, Valencia', 3, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (7, 3, N'C/Yecla, 22, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (8, 4, N'C/Sorolla, 15, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
INSERT INTO [Helix6_Test].[WorkerAddress] ([Id], [WorkerId], [Address], [AddressTypeId], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) VALUES (9, 5, N'C/Creu, 12, Valencia', 1, N'1#admin', N'1#admin', '2023-07-25 07:15:20.847', '2023-07-25 07:15:20.847', NULL)
SET IDENTITY_INSERT [Helix6_Test].[WorkerAddress] OFF
PRINT(N'Operation applied to 9 rows out of 9')

PRINT(N'Add rows to [Helix6_Attachment].[AttachmentType]')
SET IDENTITY_INSERT [Helix6_Attachment].[AttachmentType] ON
INSERT INTO [Helix6_Attachment].[AttachmentType] ([Id], [Description], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate]) SELECT 2, N'Worker Photo', N'1#admin', N'1#hlxadm', GETDATE(), GETDATE(), NULL
WHERE NOT EXISTS (SELECT [Id] FROM [Helix6_Attachment].[AttachmentType] WHERE Id = 1)
SET IDENTITY_INSERT [Helix6_Attachment].[AttachmentType] OFF
PRINT(N'Operation applied to 1 rows out of 1')

PRINT(N'Add constraints to [Helix6_Test].[WorkerAddress]')
ALTER TABLE [Helix6_Test].[WorkerAddress] WITH CHECK CHECK CONSTRAINT [FK_WorkerAddress_AddressType]
ALTER TABLE [Helix6_Test].[WorkerAddress] WITH CHECK CHECK CONSTRAINT [FK_WorkerAddress_Worker]

PRINT(N'Add constraints to [Helix6_Test].[Worker_Project]')
ALTER TABLE [Helix6_Test].[Worker_Project] WITH CHECK CHECK CONSTRAINT [FK_Worker_Project_Project]
ALTER TABLE [Helix6_Test].[Worker_Project] WITH CHECK CHECK CONSTRAINT [FK_Worker_Project_Worker]

PRINT(N'Add constraints to [Helix6_Test].[Worker_Course]')
ALTER TABLE [Helix6_Test].[Worker_Course] WITH CHECK CHECK CONSTRAINT [FK_Worker_Course_Course]
ALTER TABLE [Helix6_Test].[Worker_Course] WITH CHECK CHECK CONSTRAINT [FK_Worker_Course_Worker]

PRINT(N'Add constraints to [Helix6_Security].[SecurityProfile_SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption]
ALTER TABLE [Helix6_Security].[SecurityProfile_SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityProfile_SecurityAccessOption_SecurityProfile]

PRINT(N'Add constraints to [Helix6_Security].[SecurityAccessOptionLevel]')
ALTER TABLE [Helix6_Security].[SecurityAccessOptionLevel] WITH CHECK CHECK CONSTRAINT [FK_SecurityAccessOptionLevel_SecurityAccessOption]

PRINT(N'Add constraints to [Helix6_Test].[Worker]')
ALTER TABLE [Helix6_Test].[Worker] WITH CHECK CHECK CONSTRAINT [FK_Worker_WorkerType]

PRINT(N'Add constraints to [Helix6_Security].[SecurityAccessOption]')
ALTER TABLE [Helix6_Security].[SecurityAccessOption] WITH CHECK CHECK CONSTRAINT [FK_SecurityAccessOption_SecurityModule]
COMMIT TRANSACTION
GO
