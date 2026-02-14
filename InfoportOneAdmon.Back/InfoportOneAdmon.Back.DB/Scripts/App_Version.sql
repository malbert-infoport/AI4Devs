PRINT (N'Add row to [Helix6_Security].[SecurityVersion]')

SET IDENTITY_INSERT [Helix6_Security].[SecurityVersion] ON

INSERT INTO [Helix6_Security].[SecurityVersion] ([Id], [Version], [Observations], [AuditCreationUser], [AuditModificationUser], [AuditCreationDate], [AuditModificationDate], [AuditDeletionDate])
SELECT 1
	,N'1.0.0'
	,N'{"changetype":[{"type":"improvement","module":[{"name":"Versión inicial del desarrollo","description":["Se genera la versión inicial de la BBDD"]}]}]}'
	,N'1#admin'
	,N'1#admin'
	,GETDATE()
	,GETDATE()
	,NULL
WHERE NOT EXISTS (
		SELECT [Id]
			,[Version]
		FROM [Helix6_Security].[SecurityVersion]
		WHERE Id = 1
		)

SET IDENTITY_INSERT [Helix6_Security].[SecurityVersion] OFF
