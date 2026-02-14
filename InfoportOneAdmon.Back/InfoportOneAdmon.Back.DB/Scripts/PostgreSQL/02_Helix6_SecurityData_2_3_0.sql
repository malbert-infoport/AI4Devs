ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityUser" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityUserGridConfiguration" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityProfile" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityAccessOptionLevel" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityCompany" DISABLE TRIGGER ALL;
ALTER TABLE "Helix6_Attachment"."Attachment" DISABLE TRIGGER ALL;

INSERT INTO "Helix6_Attachment"."AttachmentType" ("Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") OVERRIDING SYSTEM VALUE SELECT 1, 'General', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Attachment"."AttachmentType" WHERE "Id" = 1);
INSERT INTO "Helix6_Attachment"."AttachmentType" ("Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") OVERRIDING SYSTEM VALUE SELECT 2, 'Worker photo', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Attachment"."AttachmentType" WHERE "Id" = 2);

INSERT INTO "Helix6_Security"."SecurityCompanyConfiguration" ("Id", "HostEmail", "PortEmail", "UserEmail", "PasswordEmail", "DefaultCredentialsEmail", "SSLEmail", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") OVERRIDING SYSTEM VALUE SELECT 1, NULL, NULL, NULL, NULL, NULL, NULL, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityCompanyConfiguration" WHERE "Id" = 1);

INSERT INTO "Helix6_Security"."SecurityCompanyGroup" ("Id", "Name", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, N'CompanyGroup',  CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityCompanyGroup" WHERE "Id" = 1);

INSERT INTO "Helix6_Security"."SecurityModule" ("Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, N'Security', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityModule" WHERE "Id" = 1);
INSERT INTO "Helix6_Security"."SecurityModule" ("Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, N'Attachments', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityModule" WHERE "Id" = 2);
INSERT INTO "Helix6_Security"."SecurityModule" ("Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 3, N'Masters', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityModule" WHERE "Id" = 3);

INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 1, N'User customization', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 1);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 1, N'Profile query', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 2);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 3, 1, N'Profile modification', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 3);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 4, 1, N'General company configuration query', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 4);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 5, 1, N'General company configuration modification', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 5);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 6, 2, N'Attachment query', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 6);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 7, 2, N'Attachment modification', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 7);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 8, 2, N'View or download attachments', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 8);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 9, 2, N'Attachment masters query', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 9);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 10, 2, N'Attachment masters modification', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 10);
INSERT INTO "Helix6_Security"."SecurityAccessOption" ("Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 13, 3, N'Masters access', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOption"  WHERE "Id" = 13);

INSERT INTO "Helix6_Security"."SecurityCompany" ("Id", "SecurityCompanyGroupId", "Name", "Cif", "SecurityCompanyConfigurationId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 1, N'SecurityCompany', N'12345678Z2', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityCompany"  WHERE "Id" = 1);

INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 1, N'SecurityUserConfiguration', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 1);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 1, N'SecurityUserGridConfiguration', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 2);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 3, 1, N'SecurityVersion', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 3);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 4, 2, N'SecurityProfile', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 4);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 5, 3, N'SecurityProfile', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 5);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 6, 2, N'SecurityModule', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 6);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 7, 3, N'SecurityModule', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 7);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 8, 4, N'SecurityCompany', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 8);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 9, 5, N'SecurityCompany', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 9);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 10, 6, N'VTA_Attachment', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 10);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 11, 7, N'VTA_Attachment', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 11);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 12, 6, N'Attachment', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 12);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 13, 7, N'Attachment', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 13);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 14, 6, N'AttachmentType', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 14);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 15, 10, N'AttachmentType', 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 15);
INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" ("Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 16, 9, N'AttachmentType', 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityAccessOptionLevel" WHERE "Id" = 16);

INSERT INTO "Helix6_Security"."SecurityProfile" ("Id", "SecurityCompanyId", "Description", "Rol", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") OVERRIDING SYSTEM VALUE SELECT 1, 1, N'Admin55', N'HLX_admin', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile" WHERE "Id" = 1);
INSERT INTO "Helix6_Security"."SecurityProfile" ("Id", "SecurityCompanyId", "Description", "Rol", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") OVERRIDING SYSTEM VALUE SELECT 2, 1, N'Prueba', N'HLX_user', CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile" WHERE "Id" = 2);

INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 1);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 3, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 3);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 5, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 5);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 7, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 7);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 1, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 1);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 6, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 6);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 7, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 7);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 13, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 13);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 2);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 4, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 4);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 6, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 6);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 8, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 8);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 9, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 9);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 10, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 10);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 1, 13, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 1 AND "SecurityAccessOptionId" = 13);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 8, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 8);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 9, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 9);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 10, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 10);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 2, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 2);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 3, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 3);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 4, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 4);
INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" ("SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate") SELECT 2, 5, CURRENT_USER, CURRENT_USER, NOW(), NOW(), null
WHERE NOT EXISTS (SELECT "Id" FROM "Helix6_Security"."SecurityProfile_SecurityAccessOption" WHERE "SecurityProfileId" = 2 AND "SecurityAccessOptionId" = 5);


ALTER TABLE "Helix6_Security"."SecurityProfile_SecurityAccessOption" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityUser" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityUserGridConfiguration" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityProfile" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityAccessOptionLevel" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Security"."SecurityCompany" ENABLE TRIGGER ALL;
ALTER TABLE "Helix6_Attachment"."Attachment" ENABLE TRIGGER ALL;