using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace InfoportOneAdmon.Back.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate_20260214 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "admon");

            migrationBuilder.EnsureSchema(
                name: "Helix6_Attachment");

            migrationBuilder.EnsureSchema(
                name: "Helix6_Security");

            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:citext", ",,");

            migrationBuilder.CreateTable(
                name: "Application",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica requerida por Helix6 (IEntityBase)")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ApplicationId = table.Column<int>(type: "integer", nullable: false, comment: "Identificador único de negocio auto-generado inmutable")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "citext", maxLength: 200, nullable: false),
                    Acronym = table.Column<string>(type: "citext", maxLength: 10, nullable: false),
                    Description = table.Column<string>(type: "citext", maxLength: 1000, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Application", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AttachmentFile",
                schema: "Helix6_Attachment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FileContent = table.Column<string>(type: "text", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AttachmentFile", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AttachmentType",
                schema: "Helix6_Attachment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AttachmentType", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AuditLog",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Action = table.Column<string>(type: "citext", maxLength: 100, nullable: false),
                    EntityType = table.Column<string>(type: "citext", maxLength: 100, nullable: false),
                    EntityId = table.Column<int>(type: "integer", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: true),
                    Timestamp = table.Column<DateTime>(type: "timestamp", nullable: false),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AuditLog", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "EventHash",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    EntityType = table.Column<string>(type: "citext", maxLength: 100, nullable: false),
                    EntityId = table.Column<int>(type: "integer", nullable: false),
                    LastEventHash = table.Column<string>(type: "char(64)", maxLength: 64, nullable: false),
                    LastPublishedAt = table.Column<DateTime>(type: "timestamp", nullable: false),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventHash", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "OrganizationGroup",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "citext", maxLength: 200, nullable: false, comment: "Nombre del grupo de organizaciones"),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrganizationGroup", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Permissions",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityAccessOptionId = table.Column<int>(type: "integer", nullable: false),
                    SecurityAccessOption = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Controller = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    SecurityLevel = table.Column<int>(type: "integer", nullable: true),
                    Profile = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Rol = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Module = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    SecurityCompanyId = table.Column<int>(type: "integer", nullable: true),
                    SecurityCompany = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Permissions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SecurityCompanyConfiguration",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    HostEmail = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    PortEmail = table.Column<int>(type: "integer", nullable: true),
                    UserEmail = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    PasswordEmail = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    DefaultCredentialsEmail = table.Column<bool>(type: "boolean", nullable: true),
                    SSLEmail = table.Column<bool>(type: "boolean", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityCompanyConfiguration", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SecurityCompanyGroup",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityCompanyGroup", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SecurityModule",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityModule", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SecurityUserConfiguration",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Pagination = table.Column<int>(type: "integer", nullable: false),
                    ModalPagination = table.Column<int>(type: "integer", nullable: false),
                    Language = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    LastConnectionDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityUserConfiguration", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SecurityVersion",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Version = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    Observations = table.Column<string>(type: "text", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityVersion", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserCache",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica requerida por Helix6 (IEntityBase)")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Email = table.Column<string>(type: "citext", maxLength: 255, nullable: false),
                    ConsolidatedCompanyIds = table.Column<string>(type: "text", nullable: false),
                    ConsolidatedRoles = table.Column<string>(type: "text", nullable: false),
                    LastUpdated = table.Column<DateTime>(type: "timestamp", nullable: false),
                    LastEventHash = table.Column<string>(type: "char(64)", maxLength: 64, nullable: false),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserCache", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "VTA_Attachment",
                schema: "Helix6_Attachment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    AttachmentTypeId = table.Column<int>(type: "integer", nullable: false),
                    EntityId = table.Column<int>(type: "integer", nullable: false),
                    EntityName = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    EntityDescription = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    FileName = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    FileExtension = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    FileSizeKb = table.Column<int>(type: "integer", nullable: true),
                    AttachmentDescription = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    AttachmentFileId = table.Column<int>(type: "integer", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AttachmentType = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VTA_Attachment", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ApplicationModule",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ApplicationId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "citext", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "citext", maxLength: 1000, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApplicationModule", x => x.Id);
                    table.ForeignKey(
                        name: "fk_applicationmodule_application",
                        column: x => x.ApplicationId,
                        principalSchema: "admon",
                        principalTable: "Application",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ApplicationRole",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ApplicationId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "citext", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "citext", maxLength: 1000, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApplicationRole", x => x.Id);
                    table.ForeignKey(
                        name: "fk_applicationrole_application",
                        column: x => x.ApplicationId,
                        principalSchema: "admon",
                        principalTable: "Application",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ApplicationSecurity",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ApplicationId = table.Column<int>(type: "integer", nullable: false),
                    ClientId = table.Column<string>(type: "citext", maxLength: 255, nullable: false),
                    ClientSecret = table.Column<string>(type: "citext", maxLength: 512, nullable: true),
                    ClientType = table.Column<string>(type: "citext", maxLength: 50, nullable: false),
                    CredentialType = table.Column<string>(type: "citext", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "citext", maxLength: 1000, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApplicationSecurity", x => x.Id);
                    table.ForeignKey(
                        name: "fk_appsecurity_application",
                        column: x => x.ApplicationId,
                        principalSchema: "admon",
                        principalTable: "Application",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Attachment",
                schema: "Helix6_Attachment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    EntityId = table.Column<int>(type: "integer", nullable: false),
                    EntityName = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    EntityDescription = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    FileName = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    FileExtension = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    FileSizeKb = table.Column<int>(type: "integer", nullable: true),
                    AttachmentTypeId = table.Column<int>(type: "integer", nullable: true),
                    AttachmentDescription = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    AttachmentFileId = table.Column<int>(type: "integer", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attachment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Attachment_AttachmentFile_AttachmentFileId",
                        column: x => x.AttachmentFileId,
                        principalSchema: "Helix6_Attachment",
                        principalTable: "AttachmentFile",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Attachment_AttachmentType_AttachmentTypeId",
                        column: x => x.AttachmentTypeId,
                        principalSchema: "Helix6_Attachment",
                        principalTable: "AttachmentType",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Organization",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica requerida por Helix6 (IEntityBase)")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityCompanyId = table.Column<int>(type: "integer", nullable: false, comment: "Identificador único inmutable de la organización. Se propaga en claim c_ids de tokens JWT")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "citext", maxLength: 200, nullable: false),
                    Acronym = table.Column<string>(type: "citext", maxLength: 10, nullable: false),
                    TaxId = table.Column<string>(type: "citext", maxLength: 50, nullable: true),
                    Address = table.Column<string>(type: "citext", maxLength: 500, nullable: true),
                    City = table.Column<string>(type: "citext", maxLength: 100, nullable: true),
                    Country = table.Column<string>(type: "citext", maxLength: 100, nullable: true),
                    ContactEmail = table.Column<string>(type: "citext", maxLength: 255, nullable: true),
                    ContactPhone = table.Column<string>(type: "citext", maxLength: 50, nullable: true),
                    GroupId = table.Column<int>(type: "integer", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Organization", x => x.Id);
                    table.ForeignKey(
                        name: "fk_organization_group",
                        column: x => x.GroupId,
                        principalSchema: "admon",
                        principalTable: "OrganizationGroup",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "SecurityCompany",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityCompanyGroupId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Cif = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    SecurityCompanyConfigurationId = table.Column<int>(type: "integer", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityCompany", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityCompany_SecurityCompanyConfiguration_SecurityCompan~",
                        column: x => x.SecurityCompanyConfigurationId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityCompanyConfiguration",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SecurityCompany_SecurityCompanyGroup_SecurityCompanyGroupId",
                        column: x => x.SecurityCompanyGroupId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityCompanyGroup",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SecurityAccessOption",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityModuleId = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityAccessOption", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityAccessOption_SecurityModule_SecurityModuleId",
                        column: x => x.SecurityModuleId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityModule",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrganizationApplicationModule",
                schema: "admon",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false, comment: "Clave primaria técnica")
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    OrganizationId = table.Column<int>(type: "integer", nullable: false),
                    ApplicationModuleId = table.Column<int>(type: "integer", nullable: false),
                    AuditCreationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Creation User#Registry creation user"),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Creation Date#Registry creation date"),
                    AuditModificationUser = table.Column<string>(type: "citext", maxLength: 255, nullable: false, comment: "Audit - Modification User#Registry modification User"),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Modification Date#Last registry modification date"),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true, comment: "Audit - Deletion Date#Logic registry deletion date")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrganizationApplicationModule", x => x.Id);
                    table.ForeignKey(
                        name: "fk_orgappmodule_module",
                        column: x => x.ApplicationModuleId,
                        principalSchema: "admon",
                        principalTable: "ApplicationModule",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "fk_orgappmodule_organization",
                        column: x => x.OrganizationId,
                        principalSchema: "admon",
                        principalTable: "Organization",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SecurityProfile",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityCompanyId = table.Column<int>(type: "integer", nullable: false),
                    Description = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Rol = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityProfile", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityProfile_SecurityCompany_SecurityCompanyId",
                        column: x => x.SecurityCompanyId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityCompany",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SecurityUser",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityCompanyId = table.Column<int>(type: "integer", nullable: false),
                    UserIdentifier = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Login = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    DisplayName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Mail = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    OrganizationCif = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    OrganizationCode = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    OrganizationName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    SecurityUserConfigurationId = table.Column<int>(type: "integer", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityUser", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityUser_SecurityCompany_SecurityCompanyId",
                        column: x => x.SecurityCompanyId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityCompany",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SecurityUser_SecurityUserConfiguration_SecurityUserConfigur~",
                        column: x => x.SecurityUserConfigurationId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityUserConfiguration",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SecurityAccessOptionLevel",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityAccessOptionId = table.Column<int>(type: "integer", nullable: false),
                    Controller = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    SecurityLevel = table.Column<int>(type: "integer", nullable: false),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityAccessOptionLevel", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityAccessOptionLevel_SecurityAccessOption_SecurityAcce~",
                        column: x => x.SecurityAccessOptionId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityAccessOption",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SecurityProfile_SecurityAccessOption",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityProfileId = table.Column<int>(type: "integer", nullable: false),
                    SecurityAccessOptionId = table.Column<int>(type: "integer", nullable: false),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityProfile_SecurityAccessOption", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityProfile_SecurityAccessOption_SecurityAccessOption_S~",
                        column: x => x.SecurityAccessOptionId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityAccessOption",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SecurityProfile_SecurityAccessOption_SecurityProfile_Securi~",
                        column: x => x.SecurityProfileId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityProfile",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SecurityUserGridConfiguration",
                schema: "Helix6_Security",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    SecurityUserId = table.Column<int>(type: "integer", nullable: false),
                    Entity = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Description = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    DefaultConfiguration = table.Column<bool>(type: "boolean", nullable: false),
                    Configuration = table.Column<string>(type: "text", nullable: true),
                    AuditCreationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditModificationUser = table.Column<string>(type: "character varying(70)", maxLength: 70, nullable: true),
                    AuditCreationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditModificationDate = table.Column<DateTime>(type: "timestamp", nullable: true),
                    AuditDeletionDate = table.Column<DateTime>(type: "timestamp", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SecurityUserGridConfiguration", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SecurityUserGridConfiguration_SecurityUser_SecurityUserId",
                        column: x => x.SecurityUserId,
                        principalSchema: "Helix6_Security",
                        principalTable: "SecurityUser",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ApplicationModule_ApplicationId",
                schema: "admon",
                table: "ApplicationModule",
                column: "ApplicationId");

            migrationBuilder.CreateIndex(
                name: "IX_ApplicationRole_ApplicationId",
                schema: "admon",
                table: "ApplicationRole",
                column: "ApplicationId");

            migrationBuilder.CreateIndex(
                name: "IX_ApplicationSecurity_ApplicationId",
                schema: "admon",
                table: "ApplicationSecurity",
                column: "ApplicationId");

            migrationBuilder.CreateIndex(
                name: "IX_Attachment_AttachmentFileId",
                schema: "Helix6_Attachment",
                table: "Attachment",
                column: "AttachmentFileId");

            migrationBuilder.CreateIndex(
                name: "IX_Attachment_AttachmentTypeId",
                schema: "Helix6_Attachment",
                table: "Attachment",
                column: "AttachmentTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Organization_GroupId",
                schema: "admon",
                table: "Organization",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_OrganizationApplicationModule_ApplicationModuleId",
                schema: "admon",
                table: "OrganizationApplicationModule",
                column: "ApplicationModuleId");

            migrationBuilder.CreateIndex(
                name: "IX_OrganizationApplicationModule_OrganizationId",
                schema: "admon",
                table: "OrganizationApplicationModule",
                column: "OrganizationId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityAccessOption_SecurityModuleId",
                schema: "Helix6_Security",
                table: "SecurityAccessOption",
                column: "SecurityModuleId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityAccessOptionLevel_SecurityAccessOptionId",
                schema: "Helix6_Security",
                table: "SecurityAccessOptionLevel",
                column: "SecurityAccessOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityCompany_SecurityCompanyConfigurationId",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                column: "SecurityCompanyConfigurationId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityCompany_SecurityCompanyGroupId",
                schema: "Helix6_Security",
                table: "SecurityCompany",
                column: "SecurityCompanyGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityProfile_SecurityCompanyId",
                schema: "Helix6_Security",
                table: "SecurityProfile",
                column: "SecurityCompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityProfile_SecurityAccessOption_SecurityAccessOptionId",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                column: "SecurityAccessOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityProfile_SecurityAccessOption_SecurityProfileId",
                schema: "Helix6_Security",
                table: "SecurityProfile_SecurityAccessOption",
                column: "SecurityProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityUser_SecurityCompanyId",
                schema: "Helix6_Security",
                table: "SecurityUser",
                column: "SecurityCompanyId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityUser_SecurityUserConfigurationId",
                schema: "Helix6_Security",
                table: "SecurityUser",
                column: "SecurityUserConfigurationId");

            migrationBuilder.CreateIndex(
                name: "IX_SecurityUserGridConfiguration_SecurityUserId",
                schema: "Helix6_Security",
                table: "SecurityUserGridConfiguration",
                column: "SecurityUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ApplicationRole",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "ApplicationSecurity",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "Attachment",
                schema: "Helix6_Attachment");

            migrationBuilder.DropTable(
                name: "AuditLog",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "EventHash",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "OrganizationApplicationModule",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "Permissions",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityAccessOptionLevel",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityProfile_SecurityAccessOption",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityUserGridConfiguration",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityVersion",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "UserCache",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "VTA_Attachment",
                schema: "Helix6_Attachment");

            migrationBuilder.DropTable(
                name: "AttachmentFile",
                schema: "Helix6_Attachment");

            migrationBuilder.DropTable(
                name: "AttachmentType",
                schema: "Helix6_Attachment");

            migrationBuilder.DropTable(
                name: "ApplicationModule",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "Organization",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "SecurityAccessOption",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityProfile",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityUser",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "Application",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "OrganizationGroup",
                schema: "admon");

            migrationBuilder.DropTable(
                name: "SecurityModule",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityCompany",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityUserConfiguration",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityCompanyConfiguration",
                schema: "Helix6_Security");

            migrationBuilder.DropTable(
                name: "SecurityCompanyGroup",
                schema: "Helix6_Security");
        }
    }
}
