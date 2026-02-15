-- Source: 01020003_SecurityData.sql

INSERT INTO "Helix6_Security"."SecurityCompanyConfiguration" AS t (
    "Id", "HostEmail", "PortEmail", "UserEmail", "PasswordEmail", "DefaultCredentialsEmail", "SSLEmail",
    "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, NULL, NULL, NULL, NULL, NULL, NULL, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.743', '2025-07-29 09:31:23.743', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "HostEmail" = EXCLUDED."HostEmail",
    "PortEmail" = EXCLUDED."PortEmail",
    "UserEmail" = EXCLUDED."UserEmail",
    "PasswordEmail" = EXCLUDED."PasswordEmail",
    "DefaultCredentialsEmail" = EXCLUDED."DefaultCredentialsEmail",
    "SSLEmail" = EXCLUDED."SSLEmail",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


INSERT INTO "Helix6_Security"."SecurityCompanyGroup" AS t (
    "Id", "Name", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 'CompanyGroup', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.743', '2025-07-29 09:31:23.743', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "Name" = EXCLUDED."Name",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";


INSERT INTO "Helix6_Security"."SecurityModule" AS t (
    "Id", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 'Security', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (2, 'Attachments', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (3, 'Masters', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (100, 'Workers', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.707', '2025-07-29 09:31:35.707', NULL),
    (101, 'Rate', '1#hlxadmin', '1#hlxadmin', '2025-08-05 13:17:44.050', '2025-08-05 13:17:44.050', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "Description" = EXCLUDED."Description",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityAccessOption" AS t (
    "Id", "SecurityModuleId", "Description", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'User customization', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.747', '2025-07-29 09:31:23.747', NULL),
    (2, 1, 'Profile query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.750', '2025-07-29 09:31:23.750', NULL),
    (3, 1, 'Profile modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
    (4, 1, 'General company configuration query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.753', '2025-07-29 09:31:23.753', NULL),
    (5, 1, 'General company configuration modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.757', '2025-07-29 09:31:23.757', NULL),
    (6, 2, 'Attachment query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.757', '2025-07-29 09:31:23.757', NULL),
    (7, 2, 'Attachment modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.760', '2025-07-29 09:31:23.760', NULL),
    (8, 2, 'View or download attachments', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.760', '2025-07-29 09:31:23.760', NULL),
    (9, 2, 'Attachment masters query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.763', '2025-07-29 09:31:23.763', NULL),
    (10, 2, 'Attachment masters modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.763', '2025-07-29 09:31:23.763', NULL),
    (13, 3, 'Masters access', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.767', '2025-07-29 09:31:23.767', NULL),
    (100, 100, 'Worker query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (101, 100, 'Worker modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (102, 100, 'Project query', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (103, 100, 'Project modification', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.710', '2025-07-29 09:31:35.710', NULL),
    (104, 101, 'Rate query', '1#admin', '1#admin', '2025-08-05 13:18:05.510', '2025-08-05 13:18:05.510', NULL),
    (105, 101, 'Rate modification', '1#admin', '1#admin', '2025-08-05 13:18:18.533', '2025-08-05 13:18:18.533', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityModuleId" = EXCLUDED."SecurityModuleId",
    "Description" = EXCLUDED."Description",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityCompany" AS t (
    "Id", "SecurityCompanyGroupId", "Name", "Cif", "SecurityCompanyConfigurationId",
    "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'SecurityCompany', '12345678Z2', 1, '1#hlxadm', '1#hlxusr', '2025-07-29 09:31:23.770', '2023-08-03 07:31:29.110', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityCompanyGroupId" = EXCLUDED."SecurityCompanyGroupId",
    "Name" = EXCLUDED."Name",
    "Cif" = EXCLUDED."Cif",
    "SecurityCompanyConfigurationId" = EXCLUDED."SecurityCompanyConfigurationId",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityAccessOptionLevel" AS t (
    "Id", "SecurityAccessOptionId", "Controller", "SecurityLevel", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
VALUES
    (1, 1, 'SecurityUserConfiguration', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.770', '2025-07-29 09:31:23.770', NULL),
    (2, 1, 'SecurityUserGridConfiguration', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.773', '2025-07-29 09:31:23.773', NULL),
    (3, 1, 'SecurityVersion', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.773', '2025-07-29 09:31:23.773', NULL),
    (4, 2, 'SecurityProfile', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.777', '2025-07-29 09:31:23.777', NULL),
    (5, 3, 'SecurityProfile', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.780', '2025-07-29 09:31:23.780', NULL),
    (6, 2, 'SecurityModule', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.780', '2025-07-29 09:31:23.780', NULL),
    (7, 3, 'SecurityModule', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.783', '2025-07-29 09:31:23.783', NULL),
    (8, 4, 'SecurityCompany', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.783', '2025-07-29 09:31:23.783', NULL),
    (9, 5, 'SecurityCompany', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.787', '2025-07-29 09:31:23.787', NULL),
    (10, 6, 'VTA_Attachment', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.787', '2025-07-29 09:31:23.787', NULL),
    (11, 7, 'VTA_Attachment', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.790', '2025-07-29 09:31:23.790', NULL),
    (12, 6, 'Attachment', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.790', '2025-07-29 09:31:23.790', NULL),
    (13, 7, 'Attachment', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.793', '2025-07-29 09:31:23.793', NULL),
    (14, 6, 'AttachmentType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.797', '2025-07-29 09:31:23.797', NULL),
    (15, 10, 'AttachmentType', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.797', '2025-07-29 09:31:23.797', NULL),
    (16, 9, 'AttachmentType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.800', '2025-07-29 09:31:23.800', NULL),
    (100, 100, 'Worker', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (101, 100, 'WorkerType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (102, 101, 'Worker', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (104, 102, 'Project', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (105, 103, 'Project', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.717', '2025-07-29 09:31:35.717', NULL),
    (106, 100, 'Prueba', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (107, 101, 'Prueba', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (108, 100, 'VistaPrueba', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (109, 100, 'AddressType', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (111, 101, 'WorkerAddress', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (112, 100, 'Course', 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (113, 101, 'Course', 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (114, 104, 'Tarifa', 1, '1#hlxadm', '1#hlxadm', '2025-08-05 13:18:27.880', '2025-08-05 13:18:27.880', NULL),
    (115, 105, 'Tarifa', 2, '1#hlxadm', '1#hlxadm', '2025-08-05 13:18:46.700', '2025-08-05 13:18:46.700', NULL),
    (116, 104, 'VTA_Tarifa', 1, '1#hlxadm', '1#hlxadm', '2025-08-05 15:14:49.733', '2025-08-05 15:14:49.733', NULL),
    (117, 104, 'Concepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-02 14:26:15.190', '2025-09-02 14:26:15.190', NULL),
    (118, 105, 'Concepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:31.397', '2025-09-03 09:15:31.397', NULL),
    (119, 104, 'ConceptoTipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:48.150', '2025-09-03 09:15:48.150', NULL),
    (120, 105, 'ConceptoTipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:15:53.497', '2025-09-03 09:15:53.497', NULL),
    (121, 104, 'ModoCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:16.817', '2025-09-03 09:16:16.817', NULL),
    (122, 105, 'ModoCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:20.120', '2025-09-03 09:16:20.120', NULL),
    (123, 104, 'ModoCalculoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:29.130', '2025-09-03 09:16:29.130', NULL),
    (124, 105, 'ModoCalculoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:33.637', '2025-09-03 09:16:33.637', NULL),
    (125, 104, 'Recargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:44.673', '2025-09-03 09:16:44.673', NULL),
    (126, 105, 'Recargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:49.960', '2025-09-03 09:16:49.960', NULL),
    (127, 104, 'RecargoTipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:16:59.823', '2025-09-03 09:16:59.823', NULL),
    (128, 104, 'RecargoTipoServicioTarificableConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:14.017', '2025-09-03 09:17:14.017', NULL),
    (129, 105, 'RecargoTipoServicioTarificableConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:17.877', '2025-09-03 09:17:17.877', NULL),
    (130, 104, 'TarifaCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:35.757', '2025-09-03 09:17:35.757', NULL),
    (131, 105, 'TarifaCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:39.637', '2025-09-03 09:17:39.637', NULL),
    (132, 104, 'TarifaCalculoDetalle', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:48.917', '2025-09-03 09:17:48.917', NULL),
    (133, 105, 'TarifaCalculoDetalle', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:17:52.020', '2025-09-03 09:17:52.020', NULL),
    (134, 104, 'TarifaCalculoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:00.500', '2025-09-03 09:18:00.500', NULL),
    (135, 105, 'TarifaCalculoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:03.377', '2025-09-03 09:18:03.377', NULL),
    (136, 104, 'TarifaRecargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:11.577', '2025-09-03 09:18:11.577', NULL),
    (137, 105, 'TarifaRecargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:18:14.290', '2025-09-03 09:18:14.290', NULL),
    (138, 104, 'TarifaRecargoDetalle', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:09.167', '2025-09-03 09:19:09.167', NULL),
    (139, 105, 'TarifaRecargoDetalle', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:14.387', '2025-09-03 09:19:14.387', NULL),
    (140, 104, 'TarifaRecargoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:24.450', '2025-09-03 09:19:24.450', NULL),
    (141, 105, 'TarifaRecargoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:27.650', '2025-09-03 09:19:27.650', NULL),
    (142, 104, 'TarifaServicio', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:37.013', '2025-09-03 09:19:37.013', NULL),
    (143, 105, 'TarifaServicio', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:42.180', '2025-09-03 09:19:42.180', NULL),
    (144, 104, 'TipoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:50.970', '2025-09-03 09:19:50.970', NULL),
    (145, 105, 'TipoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:19:55.257', '2025-09-03 09:19:55.257', NULL),
    (146, 104, 'TipoRecargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:04.200', '2025-09-03 09:20:04.200', NULL),
    (147, 105, 'TipoRecargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:07.530', '2025-09-03 09:20:07.530', NULL),
    (148, 104, 'TipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:22.227', '2025-09-03 09:20:22.227', NULL),
    (149, 105, 'TipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:20:27.120', '2025-09-03 09:20:27.120', NULL),
    (150, 104, 'TipoTarifa', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:08.257', '2025-09-03 09:21:08.257', NULL),
    (151, 105, 'TipoTarifa', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:12.327', '2025-09-03 09:21:12.327', NULL),
    (152, 104, 'VTA_Concepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:30.060', '2025-09-03 09:21:30.060', NULL),
    (153, 105, 'VTA_Concepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:21:34.933', '2025-09-03 09:21:34.933', NULL),
    (154, 104, 'VTA_ModoCalculo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:22:18.527', '2025-09-03 09:22:18.527', NULL),
    (155, 105, 'VTA_ModoCalculo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:22:22.037', '2025-09-03 09:22:22.037', NULL),
    (156, 104, 'VTA_ModoCalculoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:28.130', '2025-09-03 09:23:28.130', NULL),
    (157, 105, 'VTA_ModoCalculoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:32.220', '2025-09-03 09:23:32.220', NULL),
    (158, 104, 'VTA_Recargo', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:23:57.837', '2025-09-03 09:23:57.837', NULL),
    (159, 105, 'VTA_Recargo', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:01.767', '2025-09-03 09:24:01.767', NULL),
    (160, 104, 'VTA_RecargoConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:11.390', '2025-09-03 09:24:11.390', NULL),
    (161, 105, 'VTA_RecargoConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:24:14.393', '2025-09-03 09:24:14.393', NULL),
    (162, 104, 'VTA_TarifaCalculoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:01.987', '2025-09-03 09:33:01.987', NULL),
    (163, 105, 'VTA_TarifaCalculoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:05.913', '2025-09-03 09:33:05.913', NULL),
    (164, 104, 'VTA_TarifaRecargoDetalleConcepto', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:14.587', '2025-09-03 09:33:14.587', NULL),
    (165, 105, 'VTA_TarifaRecargoDetalleConcepto', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:17.593', '2025-09-03 09:33:17.593', NULL),
    (166, 104, 'VTA_TipoServicioTarificable', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:25.663', '2025-09-03 09:33:25.663', NULL),
    (167, 105, 'VTA_TipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:28.770', '2025-09-03 09:33:28.770', NULL),
    (168, 104, 'VTA_TipoTarifa', 1, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:37.633', '2025-09-03 09:33:37.633', NULL),
    (169, 105, 'VTA_TipoTarifa', 2, '1#hlxadm', '1#hlxadm', '2025-09-03 09:33:40.950', '2025-09-03 09:33:40.950', NULL),
    (170, 105, 'RecargoTipoServicioTarificable', 2, '1#hlxadm', '1#hlxadm', '2025-09-23 11:43:37.513', '2025-09-23 11:43:37.513', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
    "Controller" = EXCLUDED."Controller",
    "SecurityLevel" = EXCLUDED."SecurityLevel",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityProfile" AS t (
    "Id", "SecurityCompanyId", "Description", "Rol", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 'Admin', 'HLX_admin', NULL, '1#hlxadm', '2025-07-29 09:31:23.800', '2025-07-29 09:31:23.800', NULL),
    (2, 1, 'User', 'ipvRateApi_user', '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.803', '2025-07-29 09:31:23.803', NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityCompanyId" = EXCLUDED."SecurityCompanyId",
    "Description" = EXCLUDED."Description",
    "Rol" = EXCLUDED."Rol",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";



INSERT INTO "Helix6_Security"."SecurityProfile_SecurityAccessOption" AS t (
    "Id", "SecurityProfileId", "SecurityAccessOptionId", "AuditCreationUser", "AuditModificationUser", "AuditCreationDate", "AuditModificationDate", "AuditDeletionDate"
)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.807', '2025-07-29 09:31:23.807', NULL),
    (2, 1, 3, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
    (3, 1, 5, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.810', '2025-07-29 09:31:23.810', NULL),
    (4, 1, 7, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.813', '2025-07-29 09:31:23.813', NULL),
    (5, 2, 1, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.813', '2025-07-29 09:31:23.813', NULL),
    (6, 2, 6, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.817', '2025-07-29 09:31:23.817', NULL),
    (7, 2, 7, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.820', '2025-07-29 09:31:23.820', NULL),
    (8, 2, 13, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.820', '2025-07-29 09:31:23.820', NULL),
    (9, 1, 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.823', '2025-07-29 09:31:23.823', NULL),
    (10, 1, 4, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.823', '2025-07-29 09:31:23.823', NULL),
    (11, 1, 6, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.827', '2025-07-29 09:31:23.827', NULL),
    (12, 1, 8, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.830', '2025-07-29 09:31:23.830', NULL),
    (13, 1, 9, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.830', '2025-07-29 09:31:23.830', NULL),
    (14, 1, 10, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.833', '2025-07-29 09:31:23.833', NULL),
    (15, 1, 13, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.837', '2025-07-29 09:31:23.837', NULL),
    (16, 2, 8, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.837', '2025-07-29 09:31:23.837', NULL),
    (17, 2, 9, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.840', '2025-07-29 09:31:23.840', NULL),
    (18, 2, 10, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.840', '2025-07-29 09:31:23.840', NULL),
    (19, 2, 2, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.843', '2025-07-29 09:31:23.843', NULL),
    (20, 2, 3, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.847', '2025-07-29 09:31:23.847', NULL),
    (21, 2, 4, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.847', '2025-07-29 09:31:23.847', NULL),
    (22, 2, 5, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:23.850', '2025-07-29 09:31:23.850', NULL),
    (100, 1, 101, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (101, 1, 103, '1#hlxadm', '1#hlxadm', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1202, 2, 100, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1203, 2, 101, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1204, 2, 102, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1205, 2, 103, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1213, 1, 100, '1#Nombre completo del Admin', '1#Nombre completo del Admin', '2025-07-29 09:31:35.720', '2025-07-29 09:31:35.720', NULL),
    (1214, 1, 104, NULL, NULL, NULL, NULL, NULL),
    (1215, 2, 104, NULL, NULL, NULL, NULL, NULL),
    (1216, 1, 105, NULL, NULL, NULL, NULL, NULL),
    (1217, 2, 105, NULL, NULL, NULL, NULL, NULL)
ON CONFLICT ("Id") DO UPDATE SET
    "SecurityProfileId" = EXCLUDED."SecurityProfileId",
    "SecurityAccessOptionId" = EXCLUDED."SecurityAccessOptionId",
    "AuditCreationUser" = EXCLUDED."AuditCreationUser",
    "AuditModificationUser" = EXCLUDED."AuditModificationUser",
    "AuditCreationDate" = EXCLUDED."AuditCreationDate",
    "AuditModificationDate" = EXCLUDED."AuditModificationDate",
    "AuditDeletionDate" = EXCLUDED."AuditDeletionDate";
