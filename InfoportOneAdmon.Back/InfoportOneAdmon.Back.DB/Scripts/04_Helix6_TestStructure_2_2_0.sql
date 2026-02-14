/*
Helix 6 - Test structure - 2.2.0
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
CREATE SCHEMA [Helix6_Test]
AUTHORIZATION [dbo]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[Course]'
GO
CREATE TABLE [Helix6_Test].[Course]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[VersionKey] [varchar] (100) COLLATE Modern_Spanish_CI_AS NOT NULL,
[VersionNumber] [int] NOT NULL,
[ValidityFrom] [datetime] NOT NULL,
[ValidityTo] [datetime] NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Course] on [Helix6_Test].[Course]'
GO
ALTER TABLE [Helix6_Test].[Course] ADD CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[Worker_Course]'
GO
CREATE TABLE [Helix6_Test].[Worker_Course]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[WorkerId] [int] NOT NULL,
[CourseId] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Worker_Course] on [Helix6_Test].[Worker_Course]'
GO
ALTER TABLE [Helix6_Test].[Worker_Course] ADD CONSTRAINT [PK_Worker_Course] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[Worker]'
GO
CREATE TABLE [Helix6_Test].[Worker]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (500) COLLATE Modern_Spanish_CI_AS NOT NULL,
[Surnames] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[BirthDate] [datetime] NOT NULL,
[IsTrainee] [bit] NOT NULL,
[WorkerTypeId] [int] NOT NULL,
[Age] [int] NULL,
[Height] [decimal] (4, 2) NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Worker] on [Helix6_Test].[Worker]'
GO
ALTER TABLE [Helix6_Test].[Worker] ADD CONSTRAINT [PK_Worker] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [Helix6_Test].[Worker]'
GO
ALTER TABLE [Helix6_Test].[Worker] ADD CONSTRAINT [UK_Worker] UNIQUE NONCLUSTERED ([Name], [Surnames], [AuditDeletionDate]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[Project]'
GO
CREATE TABLE [Helix6_Test].[Project]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (200) COLLATE Modern_Spanish_CI_AS NOT NULL,
[VersionKey] [varchar] (100) COLLATE Modern_Spanish_CI_AS NOT NULL,
[VersionNumber] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Project] on [Helix6_Test].[Project]'
GO
ALTER TABLE [Helix6_Test].[Project] ADD CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[Worker_Project]'
GO
CREATE TABLE [Helix6_Test].[Worker_Project]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[WorkerId] [int] NOT NULL,
[ProjectId] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Worker_Project] on [Helix6_Test].[Worker_Project]'
GO
ALTER TABLE [Helix6_Test].[Worker_Project] ADD CONSTRAINT [PK_Worker_Project] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[WorkerType]'
GO
CREATE TABLE [Helix6_Test].[WorkerType]
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
PRINT N'Creating primary key [PK_WorkerType] on [Helix6_Test].[WorkerType]'
GO
ALTER TABLE [Helix6_Test].[WorkerType] ADD CONSTRAINT [PK_WorkerType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[AddressType]'
GO
CREATE TABLE [Helix6_Test].[AddressType]
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
PRINT N'Creating primary key [PK_AddressType] on [Helix6_Test].[AddressType]'
GO
ALTER TABLE [Helix6_Test].[AddressType] ADD CONSTRAINT [PK_AddressType] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[WorkerAddress]'
GO
CREATE TABLE [Helix6_Test].[WorkerAddress]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[WorkerId] [int] NOT NULL,
[Address] [varchar] (1000) COLLATE Modern_Spanish_CI_AS NOT NULL,
[AddressTypeId] [int] NOT NULL,
[AuditCreationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditModificationUser] [varchar] (70) COLLATE Modern_Spanish_CI_AS NULL,
[AuditCreationDate] [datetime] NULL,
[AuditModificationDate] [datetime] NULL,
[AuditDeletionDate] [datetime] NULL
) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_WorkerAddress] on [Helix6_Test].[WorkerAddress]'
GO
ALTER TABLE [Helix6_Test].[WorkerAddress] ADD CONSTRAINT [PK_WorkerAddress] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [Helix6_Test].[VTA_Worker]'
GO
CREATE VIEW [Helix6_Test].[VTA_Worker]
AS
SELECT        Helix6_Test.Worker.Id, Helix6_Test.Worker.Name, Helix6_Test.Worker.Surnames, Helix6_Test.Worker.BirthDate, Helix6_Test.Worker.IsTrainee, Helix6_Test.WorkerType.Description AS WorkerType, Helix6_Test.Worker.Age, 
                         Helix6_Test.Worker.Height, Helix6_Test.Worker.AuditCreationUser, Helix6_Test.Worker.AuditCreationDate, Helix6_Test.Worker.AuditModificationUser, Helix6_Test.Worker.AuditModificationDate, 
                         Helix6_Test.Worker.AuditDeletionDate
FROM            Helix6_Test.Worker INNER JOIN
                         Helix6_Test.WorkerType ON Helix6_Test.Worker.WorkerTypeId = Helix6_Test.WorkerType.Id
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Test].[WorkerAddress]'
GO
ALTER TABLE [Helix6_Test].[WorkerAddress] ADD CONSTRAINT [FK_WorkerAddress_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [Helix6_Test].[AddressType] ([Id])
GO
ALTER TABLE [Helix6_Test].[WorkerAddress] ADD CONSTRAINT [FK_WorkerAddress_Worker] FOREIGN KEY ([WorkerId]) REFERENCES [Helix6_Test].[Worker] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Test].[Worker]'
GO
ALTER TABLE [Helix6_Test].[Worker] ADD CONSTRAINT [FK_Worker_WorkerType] FOREIGN KEY ([WorkerTypeId]) REFERENCES [Helix6_Test].[WorkerType] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Test].[Worker_Course]'
GO
ALTER TABLE [Helix6_Test].[Worker_Course] ADD CONSTRAINT [FK_Worker_Course_Course] FOREIGN KEY ([CourseId]) REFERENCES [Helix6_Test].[Course] ([Id])
GO
ALTER TABLE [Helix6_Test].[Worker_Course] ADD CONSTRAINT [FK_Worker_Course_Worker] FOREIGN KEY ([WorkerId]) REFERENCES [Helix6_Test].[Worker] ([Id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Helix6_Test].[Worker_Project]'
GO
ALTER TABLE [Helix6_Test].[Worker_Project] ADD CONSTRAINT [FK_Worker_Project_Project] FOREIGN KEY ([ProjectId]) REFERENCES [Helix6_Test].[Project] ([Id])
GO
ALTER TABLE [Helix6_Test].[Worker_Project] ADD CONSTRAINT [FK_Worker_Project_Worker] FOREIGN KEY ([WorkerId]) REFERENCES [Helix6_Test].[Worker] ([Id])
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
