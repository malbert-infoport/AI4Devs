

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